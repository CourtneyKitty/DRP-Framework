---------------------------------------------------------------------------
-- Event Handlers And Callbacks
---------------------------------------------------------------------------
AddEventHandler("DRP_Inventory:GetInventorySize", function(source, callback)
    local src = source
    local characterInfo = exports["drp_id"]:GetCharacterData(src)
    exports["externalsql"]:DBAsyncQuery({
        string = "SELECT * FROM `character_inventory` WHERE `charid` = :char_id",
        data = {
            char_id = characterInfo.charid
        }
    }, function(inventorySize)
        local results = inventorySize["data"]
        local maxQuantity = 20
        local quantityAmount = 0

        for a = 1, #results do
            quantityAmount = quantityAmount + results[a].quantity
        end
        callback(quantityAmount)
    end)
end)

AddEventHandler("DRP_Inventory:CheckForItemOwnershipById", function(source, itemid, callback)
    local src = source
    local characterInfo = exports["drp_id"]:GetCharacterData(src)
    exports["externalsql"]:DBAsyncQuery({
        string = "SELECT * FROM `character_inventory` WHERE `charid` = :char_id and `itemid` = :itemid",
        data = {
            char_id = characterInfo.charid,
            itemid = itemid
        }
    }, function(CheckForItemOwnership)
        callback(CheckForItemOwnership.data)
    end)
end)

AddEventHandler("DRP_Inventory:CheckForItemOwnershipByName", function(source, itemname, callback)
    local src = source
    local characterInfo = exports["drp_id"]:GetCharacterData(src)
    exports["externalsql"]:DBAsyncQuery({
        string = "SELECT * FROM `character_inventory` WHERE `charid` = :char_id and `name` = :itemname",
        data = {
            char_id = characterInfo.charid,
            itemname = itemname
        }
    }, function(CheckForItemOwnership)
        callback(CheckForItemOwnership.data)
    end)
end)

AddEventHandler("DRP_Inventory:PullItemData", function(itemname, callback)
    exports["externalsql"]:DBAsyncQuery({
        string = "SELECT * FROM `inventory_items` WHERE `itemname` = :itemname",
        data = {
            itemname = itemname
        }
    }, function(allDataInfo)
        callback(allDataInfo["data"][1].id)
    end)
end)


AddEventHandler("DRP_Inventory:GetCharacterInventory", function(source, callback)
    local src = source
    local character = exports["drp_id"]:GetCharacterData(src)
    exports["externalsql"]:DBAsyncQuery({
        string = "SELECT * FROM `character_inventory` WHERE `charid` = :char_id",
        data = {
            char_id = character.charid
        }
    }, function(inventoryResults)
        callback(inventoryResults["data"])
    end)
end)

AddEventHandler("DRP_Inventory:RemoveItemFromInventory", function(source, itemname) -- Triggered from server side only to pass source
    local src = source
    local itemname = itemname
    local character = exports["drp_id"]:GetCharacterData(src)
    TriggerEvent("DRP_Inventory:CheckForItemOwnershipByName", src, itemname, function(Ownership)
        local quantity = Ownership[1].quantity
        local newquantity = quantity - 1
        if newquantity ~= 0 then
            exports["externalsql"]:DBAsyncQuery({
                string = "UPDATE character_inventory SET `quantity` = :newamount WHERE `charid` = :char_id and `name` = :itemname",
                data = {
                    newamount = newquantity,
                    char_id = character.charid,
                    itemname = itemname
                }
            }, function(yeet)
            end)
        else
            exports["externalsql"]:DBAsyncQuery({
                string = "DELETE FROM `character_inventory` WHERE `charid` = :char_id and `name` = :itemname",
                data = {
                    char_id = character.charid,
                    itemname = itemname
                }
            }, function(yeeting)
            end)
        end
    end)
end)
---------------------------------------------------------------------------
-- Manager Functions
---------------------------------------------------------------------------
function AddItem(source, itemname, amount)
    print(itemname)
    local src = source
    local itemname = string.lower(itemname)
    local character = exports["drp_id"]:GetCharacterData(src)
    if itemname ~= nil then
        TriggerEvent("DRP_Inventory:GetInventorySize", src, function(AmountOfSpace)
            if AmountOfSpace >= DRPInventory.MaxInventorySlots then
                TriggerClientEvent("DRP_Core:Error", src, "Inventory", "You have no Inventory space left", 2500, false, "leftCenter")
            else
                TriggerEvent("DRP_Inventory:CheckForItemOwnershipByName", src, itemname, function(Ownership)
                    if json.encode(Ownership) == "[]" then
                        TriggerEvent("DRP_Inventory:PullItemData", itemname, function(itemInfoId)
                            print("adding whole new item")
                            exports["externalsql"]:DBAsyncQuery({
                                string = "INSERT INTO `character_inventory` SET `name` = :itemname, `quantity` = :amount, `itemid` = :itemid, `charid` = :charid",
                                data = {
                                    itemname = itemname,
                                    amount = amount,
                                    itemid = itemInfoId,
                                    charid = character.charid
                                }
                            }, function(createdPlayer)
                                TriggerClientEvent("DRP_Core:Info", src, "Inventory", "Added "..amount.."x "..itemname, 2500, false, "leftCenter")
                            end)
                        end)
                        else
                            local amountToAdd = amount + Ownership[1].quantity
                            exports["externalsql"]:DBAsyncQuery({
                                string = "UPDATE character_inventory SET `quantity` = :amount WHERE `charid` = :charid and `name` = :itemname",
                                data = {
                                    amount = amountToAdd,
                                    charid = character.charid,
                                    itemname = itemname
                                }
                            }, function(updatedQuantity)
                            TriggerClientEvent("DRP_Core:Info", src, "Inventory", "Added "..amount.."x "..itemname, 2500, false, "leftCenter")
                        end)
                    end
                end)
            end
        end)
    end
end
------------------------------------------------------------------------------------
function CheckForItemOwnershipByName(source, itemname)
    local src = source
    local character = exports["drp_id"]:GetCharacterData(src)
    print(itemname)
    exports["externalsql"]:DBAsyncQuery({
        string = "SELECT * FROM `character_inventory` WHERE `charid` = :char_id and `name` = :itemname",
        data = {
            char_id = character.charid,
            itemname = itemname
        }
    }, function(CheckForItemOwnership)
        print(json.encode(CheckForItemOwnership.data))
        return CheckForItemOwnership.data
    end)
end