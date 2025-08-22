document.addEventListener('DOMContentLoaded', () => {
    const shopContainer = document.getElementById('shop-container');
    const categoryListDiv = document.getElementById('category-list');
    const itemsGrid = document.getElementById('items-grid');
    const cartItemsDiv = document.getElementById('cart-items');
    const totalPriceSpan = document.getElementById('total-price');
    const payCashBtn = document.getElementById('pay-cash');
    const payCardBtn = document.getElementById('pay-card');
    const emptyCartBtn = document.getElementById('empty-cart-btn');

    let shopCategories = {};
    let cart = [];

    const isFiveM = 'GetParentResourceName' in window;


    const mockCategories = {
        "Food": { label: "Food & Drinks", items: [{ name: "water", label: "Water", price: 5, imageUrl: "https://placehold.co/80x80/2a2d34/f0f0f0?text=Water" }] },
        "Electronics": { label: "Electronics", items: [{ name: "phone", label: "Phone", price: 500, imageUrl: "https://placehold.co/80x80/2a2d34/f0f0f0?text=Phone" }] }
    };


    let isDragging = false;
    let offsetX, offsetY;

    const onMouseDown = (e) => {
        if (e.button !== 0 || !e.target.closest('.drag-handle')) return;
        isDragging = true;
        const rect = shopContainer.getBoundingClientRect();
        offsetX = e.clientX - rect.left;
        offsetY = e.clientY - rect.top;
        document.addEventListener('mousemove', onMouseMove);
        document.addEventListener('mouseup', onMouseUp);
    };

    const onMouseMove = (e) => {
        if (!isDragging) return;
        e.preventDefault();
        let newX = e.clientX - offsetX;
        let newY = e.clientY - offsetY;
        newX = Math.max(0, Math.min(newX, window.innerWidth - shopContainer.offsetWidth));
        newY = Math.max(0, Math.min(newY, window.innerHeight - shopContainer.offsetHeight));
        shopContainer.style.left = `${newX}px`;
        shopContainer.style.top = `${newY}px`;
        shopContainer.style.transform = 'none';
    };

    const onMouseUp = () => {
        isDragging = false;
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);
    };

    shopContainer.addEventListener('mousedown', onMouseDown);


    function openShopUI(categories) {
        document.body.style.display = 'block';
        shopCategories = categories;
        renderCategories();
        if (Object.keys(shopCategories).length > 0) {
            const firstCategoryKey = Object.keys(shopCategories)[0];
            const firstTab = document.querySelector('.category-tab');
            if(firstTab) firstTab.classList.add('active');
            renderItems(firstCategoryKey);
        }
        renderCart();
    }

    function closeShop() {
        document.body.style.display = 'none';
        cart = [];
        renderCart();
        shopContainer.style.top = '50%';
        shopContainer.style.left = '50%';
        shopContainer.style.transform = 'translate(-50%, -50%)';
        if (isFiveM) {
            fetch(`https://henny_ox_shop/close`, { method: 'POST', body: '{}' });
        }
    }
    
    function renderCategories() {
        categoryListDiv.innerHTML = '';
        for (const key in shopCategories) {
            const category = shopCategories[key];
            const tab = document.createElement('div');
            tab.className = 'category-tab';
            tab.textContent = category.label;
            tab.onclick = () => {
                document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');
                renderItems(key);
            };
            categoryListDiv.appendChild(tab);
        }
    }

    function renderItems(categoryKey) {
        itemsGrid.innerHTML = '';
        const category = shopCategories[categoryKey];
        if (!category) return;

        category.items.forEach(item => {

            const imageUrl = item.imageUrl;
            
            const itemDiv = document.createElement('div');
            itemDiv.className = 'item';
            itemDiv.innerHTML = `
                <div>
                    <img src="${imageUrl}" alt="${item.label}" class="item-image">
                    <div class="item-name">${item.label}</div>
                    <div class="item-price">$${item.price}</div>
                </div>
                <div>
                    <div class="item-quantity">
                        <input type="number" value="1" min="1" max="100" oninput="this.value = Math.max(1, parseInt(this.value)) || 1;">
                    </div>
                    <button class="add-to-cart">Add to Cart</button>
                </div>
            `;
            itemDiv.querySelector('.add-to-cart').onclick = () => {
                const quantity = parseInt(itemDiv.querySelector('input').value);
                addToCart(item, quantity);
            };
            itemsGrid.appendChild(itemDiv);
        });
    }

    function addToCart(item, quantity) {
        if (isNaN(quantity) || quantity <= 0) return;
        const existingItem = cart.find(i => i.name === item.name);
        if (existingItem) {
            existingItem.quantity += quantity;
        } else {
            cart.push({ ...item, quantity });
        }
        renderCart();
    }

    function renderCart() {
        cartItemsDiv.innerHTML = '';
        let totalPrice = 0;
        if (cart.length === 0) {
            cartItemsDiv.innerHTML = '<div class="empty-cart-message">Your cart is empty.</div>';
        } else {
            cart.forEach((item, index) => {
                const cartItemDiv = document.createElement('div');
                cartItemDiv.className = 'cart-item';
                cartItemDiv.innerHTML = `
                    <div class="cart-item-details">
                        <span class="cart-item-name">${item.label}</span>
                        <span class="cart-item-quantity">x${item.quantity} @ $${item.price}</span>
                    </div>
                    <span class="cart-item-price">$${item.price * item.quantity}</span>
                    <button class="remove-from-cart" data-index="${index}"><i class="fa-solid fa-xmark"></i></button>
                `;
                cartItemsDiv.appendChild(cartItemDiv);
                totalPrice += item.price * item.quantity;
            });
        }
        totalPriceSpan.textContent = `$${totalPrice}`;
        document.querySelectorAll('.remove-from-cart').forEach(button => {
            button.onclick = (e) => {
                const indexToRemove = parseInt(e.currentTarget.dataset.index);
                cart.splice(indexToRemove, 1);
                renderCart();
            };
        });
    }

    function purchase(paymentMethod) {
        if (cart.length === 0) return;
        if (isFiveM) {
            fetch(`https://henny_ox_shop/purchase`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ cart, paymentMethod })
            }).then(closeShop);
        } else {
            console.log(`Browser Preview: Purchasing with ${paymentMethod}.`);
            console.log('Cart:', cart);
            closeShop();
        }
    }

    if (isFiveM) {
        window.addEventListener('message', (event) => {
            const { action, categories } = event.data;
            if (action === 'open') {
                openShopUI(categories);
            }
        });
    }

    document.addEventListener('keydown', (e) => {
        if (e.key.toLowerCase() === 't' && !isFiveM) {
            if (document.body.style.display === 'none' || document.body.style.display === '') {
                openShopUI(mockCategories);
            }
        }
        if (e.key === 'Escape') {
            closeShop();
        }
    });

    payCashBtn.onclick = () => purchase('cash');
    payCardBtn.onclick = () => purchase('card');
    emptyCartBtn.onclick = () => {
        cart = [];
        renderCart();
    };
});
