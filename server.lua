local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('addItemToInventoryServer', function(item, ammount)
    local player = QBCore.Functions.GetPlayer(source)  
    
    if player then
        player.Functions.AddItem(item, ammount) 
        
  
        TriggerClientEvent('QBCore:Notify', source, 'تم استلام شحنتك', 'success')  

    else
        TriggerClientEvent('QBCore:Notify', source, 'حدث خطأ أثناء إضافة العنصر.', 'error')  -- إشعار في حال حدث خطأ
    end
end)
