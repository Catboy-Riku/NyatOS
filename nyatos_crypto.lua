local aes = dofile("aes.lua")
local sha = dofile("sha2.lua")

local crypto = {}

-- Helpers

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

local nonceCounter = 0

local function makeNonce()
    nonceCounter =
        nonceCounter + 1

    local source =
        tostring(os.epoch("utc"))
        .. ":"
        .. tostring(os.getComputerID())
        .. ":"
        .. tostring(nonceCounter)

    local digest =
        sha.sha256(source)

    return hexToBinary(
        digest:sub(1, 32)
    )
end

function crypto.encrypt(masterKey, plaintext, associatedData)
    if type(masterKey) ~= "string"
        or #masterKey < 16
    then
        return false, nil, "Encryption key is too short."
    end

    if type(plaintext) ~= "string" then
        return false, nil, "Plaintext must be a string."
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

    local nonce =
        makeNonce()

    local cipher =
        Cipher:new(
            nil,
            encryptionKey,
            {
                string.byte(nonce, 1, 4)
                    ,
                string.byte(nonce, 5, 8)
                    ,
                string.byte(nonce, 9, 12)
                    ,
                string.byte(nonce, 13, 16)
            }
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
        hexToBinary(
            sha.hmac(
                sha.sha256,
                authenticationKey,
                authenticatedData
            )
        )

    return true, {
        nonce = nonce,
        ciphertext = ciphertext,
        mac = mac
    }
end

function crypto.decrypt(masterKey, packet, associatedData)
    if type(masterKey) ~= "string"
        or #masterKey < 16
    then
        return false, nil, "Encryption key is too short."
    end

    if type(packet) ~= "table"
        or type(packet.nonce) ~= "string"
        or type(packet.ciphertext) ~= "string"
        or type(packet.mac) ~= "string"
    then
        return false, nil, "Invalid encrypted packet."
    end

    if #packet.nonce ~= 16 then
        return false, nil, "Invalid nonce."
    end

    if #packet.mac ~= 32 then
        return false, nil, "Invalid authentication code."
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
        hexToBinary(
            sha.hmac(
                sha.sha256,
                authenticationKey,
                authenticatedData
            )
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
        Cipher:new(
            nil,
            encryptionKey,
            {
                string.byte(packet.nonce, 1, 4)
                    ,
                string.byte(packet.nonce, 5, 8)
                    ,
                string.byte(packet.nonce, 9, 12)
                    ,
                string.byte(packet.nonce, 13, 16)
            }
        )

    local plaintext =
        cipher:decrypt(
            packet.ciphertext
        )

    return true, plaintext
end

crypto.constantTimeEquals =
    constantTimeEquals

return crypto
