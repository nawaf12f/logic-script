window.addEventListener('message', function(event) {
    if (event.data.action === "openMenu") {
        let container = document.querySelector('.container');
        let ordersDiv = document.getElementById('orders');
        
        ordersDiv.innerHTML = "";
        
        document.getElementById('amm').value = "";

        event.data.orders.forEach(order => {
            let orderItem = document.createElement('div');
            orderItem.classList.add('order-item');
            
            let image = document.createElement('img');
            image.src = getImageForOrderType(order.type);
            image.alt = order.name;
            image.classList.add('order-image');
            image.style.width = "100%";
            image.style.borderRadius = "10px";
            orderItem.appendChild(image);

            let nameDiv = document.createElement('div');
            nameDiv.innerText = order.name;
            nameDiv.classList.add('item-name');
            orderItem.appendChild(nameDiv);

            let descriptionDiv = document.createElement('p');
            descriptionDiv.innerText = getDescriptionForOrderType(order.type);
            descriptionDiv.style.color = 'white';
            descriptionDiv.style.fontSize = '14px';
            descriptionDiv.style.marginBottom = '10px';
            orderItem.appendChild(descriptionDiv);
            
            let button = document.createElement('button');
            button.classList.add('order-btn');
            button.innerText = "طلب";
            
            button.addEventListener('click', function() {
                let inputValue = document.getElementById('amm').value;
                console.log("نوع الطلب: ", order.type);
                console.log("المعلومات الإضافية: ", inputValue);
                fetch(`https://${GetParentResourceName()}/placeOrder`, {
                    method: "POST",
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        orderType: order.type,
                        amma: inputValue
                    })
                });
                
                closeMenu();
            });
            
            orderItem.appendChild(button);
            
            ordersDiv.appendChild(orderItem);
        });

        container.style.display = 'block';
    }
});

function getImageForOrderType(type) {
    const images = {
        "food": "images/food.jpg",
        "drink": "images/drink.jpg",
        "weapon_pistol": "https://i.pinimg.com/236x/c4/48/3f/c4483f752a787d9457ae41e34b94cbdb.jpg",
        "pistiol_ammo": "https://i.pinimg.com/236x/6c/8f/6c/6c8f6c77d2e1a84392729268906a89e4.jpg",
        "AK_Raifl": "https://i.pinimg.com/736x/10/c3/9d/10c39d9fb0c2dda029dc1202b7027e02.jpg",
        "Ak_ammo": "https://i.pinimg.com/236x/cc/01/8c/cc018cccd1e93b5af0f483f105328621.jpg",
        "default": "images/default.jpg"
    };
    
    return images[type] || images.default;
}

function getDescriptionForOrderType(type) {
    const descriptions = {
        "food": "وجبة شهية لذيذة!",
        "drink": "مشروب بارد ومنعش!",
        "weapon_pistol": "مسدس قوي للحماية .",
        "pistiol_ammo": "ذخيرة متينة للمسدس.",
        "AK_Raifl": "سلاح AK قوي وفعال",
        "Ak_ammo": "ذخيرة AK قوية للاستخدام ",
        "default": "منتج رائع ومميز!"
    };
    
    return descriptions[type] || descriptions.default;
}

function closeMenu() {
    document.querySelector('.container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeMenu`, { method: "POST" });
}

document.addEventListener("keydown", function(event) {
    if (event.key === "Escape") {
        closeMenu();
    }
});
