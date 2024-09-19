import { backend } from 'declarations/backend';

// Helper function to update displayed balances
async function updateBalances() {
    const userBalances = await backend.getUserBalances();
    const liquidityPool = await backend.getLiquidityPoolBalances();

    document.getElementById('userBalances').innerHTML = userBalances.map(([token, balance]) => 
        `${token}: ${balance.toFixed(2)}`
    ).join('<br>');

    document.getElementById('liquidityPool').innerHTML = liquidityPool.map(([token, balance]) => 
        `${token}: ${balance.toFixed(2)}`
    ).join('<br>');
}

// Mint tokens
window.mintTokens = async function() {
    const token = document.getElementById('mintToken').value;
    const amount = parseFloat(document.getElementById('mintAmount').value);
    
    if (amount > 0) {
        await backend.mintTokens(token, amount);
        await updateBalances();
    }
}

// Add liquidity
window.addLiquidity = async function() {
    const amountA = parseFloat(document.getElementById('addLiquidityA').value);
    const amountB = parseFloat(document.getElementById('addLiquidityB').value);
    
    if (amountA > 0 && amountB > 0) {
        await backend.addLiquidity(amountA, amountB);
        await updateBalances();
    }
}

// Remove liquidity
window.removeLiquidity = async function() {
    const amountA = parseFloat(document.getElementById('removeLiquidityA').value);
    const amountB = parseFloat(document.getElementById('removeLiquidityB').value);
    
    if (amountA > 0 && amountB > 0) {
        await backend.removeLiquidity(amountA, amountB);
        await updateBalances();
    }
}

// Swap tokens
window.swap = async function() {
    const fromToken = document.getElementById('fromToken').value;
    const toToken = document.getElementById('toToken').value;
    const amount = parseFloat(document.getElementById('swapAmount').value);
    
    if (amount > 0 && fromToken !== toToken) {
        const received = await backend.swap(fromToken, toToken, amount);
        alert(`Swapped ${amount} ${fromToken} for ${received.toFixed(2)} ${toToken}`);
        await updateBalances();
    }
}

// Initial update of balances
updateBalances();
