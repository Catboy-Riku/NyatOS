dofile("aes.lua")

local sha = dofile("sha2.lua")

local crypto = {}

local function hexToBinary(hex)
    return sha.hex_to_bin(hex)
end

local function deriveKey(masterKey, label)
    local digest =
        sha.sha256(
            masterKey
            .. "\0"
            .. label
        )

    return hexToBinary(digest)
end

local function constantTimeEquals(a, b)
    if type(a) ~= "string"
        or type(b) ~= "string"
    then
        return false
    end

    if #a ~= #b then
        return false
    end

    local difference = 0

    for i = 1, #a do
        difference =
            bit32.bor(
                difference,
                bit32.bxor(
                    string.byte(a, i),
                    string.byte(b, i)
                )
            )
    end

    return difference == 0
end

local function hmacSha256(key, message)
    return hexToBinary(
        sha.hmac(
            sha.sha256,
            key,
            message
        )
    )
end

local function loadNonceCounters(nonceFile)
    if not fs.exists(nonceFile) then
        return {}
    end

    local file, err =
        fs.open(
            nonceFile,
            "r"
        )

    if not file then
        error(
            "Could not open nonce file: "
            .. tostring(err)
        )
    end

    local contents =
        file.readAll()

    file.close()

    if contents == "" then
        return {}
    end

    local counters =
        textutils.unserialize(
            contents
        )

    if type(counters) ~= "table" then
        error(
            "Nonce file is corrupted: "
            .. tostring(nonceFile)
        )
    end

    return counters
end

local function saveNonceCounters(
    nonceFile,
    counters
)
    local file, err =
        fs.open(
            nonceFile,
            "w"
        )

    if not file then
        error(
            "Could not write nonce file: "
            .. tostring(err)
        )
    end

    file.write(
        textutils.serialize(
            counters
        )
    )

    file.close()
end

local function nextNonce(
    masterKey,
    nonceFile,
    context
)
    if type(nonceFile) ~= "string"
        or nonceFile == ""
    then
        return false,
            nil,
            "Nonce file was not specified."
    end

    if type(context) ~= "string"
        or context == ""
    then
        return false,
            nil,
            "Nonce context was not specified."
    end

    local loadOK,
        counters =
        pcall(
            function()
                return loadNonceCounters(
                    nonceFile
                )
            end
        )

    if not loadOK then
        return false,
            nil,
            counters
    end

    local counter =
        tonumber(
            counters[context]
        )

    if counter == nil then
        counter = 0
    end

    counter =
        counter + 1

    counters[context] =
        counter

    local saveOK,
        saveError =
        pcall(
            function()
                saveNonceCounters(
                    nonceFile,
                    counters
                )
            end
        )

    if not saveOK then
        return false,
            nil,
            saveError
    end

    local nonceSource =
        context
        .. "\0"
        .. tostring(counter)

    local nonceDigest =
        sha.sha256(
            masterKey
            .. "\0"
            .. nonceSource
        )

    local nonce =
        hexToBinary(
            nonceDigest:sub(
                1,
                32
            )
        )

    return true,
        nonce
end

local function makeCipher(
    key,
    nonce
)
    return Cipher:new(
        nil,
        key,
        {
            string.byte(
                nonce,
                1,
                4
            ),

            string.byte(
                nonce,
                5,
                8
            ),

            string.byte(
                nonce,
                9,
                12
            ),

            string.byte(
                nonce,
                13,
                16
            )
        }
    )
end

local function encryptWithNonce(
    masterKey,
    plaintext,
    associatedData,
    nonce
)
    if type(masterKey) ~= "string"
        or #masterKey < 16
    then
        return false,
            nil,
            "Encryption key is too short."
    end

    if type(plaintext) ~= "string" then
        return false,
            nil,
            "Plaintext must be a string."
    end

    if type(nonce) ~= "string"
        or #nonce ~= 16
    then
        return false,
            nil,
            "Invalid nonce."
    end

    associatedData =
        associatedData or ""

    local encryptionKey =
        deriveKey(
            masterKey,
            "NyatOS encryption"
        )

    local authenticationKey =
        deriveKey(
            masterKey,
            "NyatOS authentication"
        )

    local cipher =
        makeCipher(
            encryptionKey,
            nonce
        )

    local ciphertext =
        cipher:encrypt(
            plaintext
        )

    local authenticatedData =
        associatedData
        .. "\0"
        .. nonce
        .. ciphertext

    local mac =
        hmacSha256(
            authenticationKey,
            authenticatedData
        )

    return true, {
        nonce = nonce,
        ciphertext = ciphertext,
        mac = mac
    }
end

function crypto.encrypt(
    masterKey,
    plaintext,
    associatedData,
    nonceFile,
    nonceContext
)
    local nonceOK,
        nonce,
        nonceError =
        nextNonce(
            masterKey,
            nonceFile,
            nonceContext
        )

    if not nonceOK then
        return false,
            nil,
            nonceError
    end

    return encryptWithNonce(
        masterKey,
        plaintext,
        associatedData,
        nonce
    )
end

function crypto.decrypt(
    masterKey,
    packet,
    associatedData
)
    if type(masterKey) ~= "string"
        or #masterKey < 16
    then
        return false,
            nil,
            "Encryption key is too short."
    end

    if type(packet) ~= "table"
        or type(packet.nonce) ~= "string"
        or type(packet.ciphertext) ~= "string"
        or type(packet.mac) ~= "string"
    then
        return false,
            nil,
            "Invalid encrypted packet."
    end

    if #packet.nonce ~= 16 then
        return false,
            nil,
            "Invalid nonce."
    end

    if #packet.mac ~= 32 then
        return false,
            nil,
            "Invalid authentication code."
    end

    associatedData =
        associatedData or ""

    local encryptionKey =
        deriveKey(
            masterKey,
            "NyatOS encryption"
        )

    local authenticationKey =
        deriveKey(
            masterKey,
            "NyatOS authentication"
        )

    local authenticatedData =
        associatedData
        .. "\0"
        .. packet.nonce
        .. packet.ciphertext

    local expectedMac =
        hmacSha256(
            authenticationKey,
            authenticatedData
        )

    if not constantTimeEquals(
        expectedMac,
        packet.mac
    ) then
        return false,
            nil,
            "Message authentication failed."
    end

    local cipher =
        makeCipher(
            encryptionKey,
            packet.nonce
        )

    local plaintext =
        cipher:decrypt(
            packet.ciphertext
        )

    return true,
        plaintext
end

crypto.constantTimeEquals =
    constantTimeEquals

function crypto.generateKey()
    local source =
        tostring(
            os.epoch("utc")
        )
        .. "\0"
        .. tostring(
            os.getComputerID()
        )
        .. "\0"
        .. tostring(
            math.random(
                1,
                2147483647
            )
        )
        .. "\0"
        .. tostring(
            math.random(
                1,
                2147483647
            )
        )
        .. "\0"
        .. tostring(
            math.random(
                1,
                2147483647
            )
        )

    return sha.sha256(source)
end

return crypto
