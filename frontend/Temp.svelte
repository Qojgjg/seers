<!-- <div>Liquidity: {market.liquidity}</div>
        <div>Reserve Yes: {market.reserveYes}</div>
        <div>Reserve No: {market.reserveNo}</div>
        <div>K Last: {market.kLast}</div>
        <div>Total shares: {market.totalShares}</div>
        <div>Providers: {market.providers}</div>
        <div>
          Created: {new Date(
            Math.trunc(Number(market.startDate) / 1_000_000),
          ).toDateString()}
        </div>
        <div>
          End date: {new Date(
            Number(market.endDate) / 1_000_000,
          ).toDateString()}
        </div>
        <div>Author: {market.author}</div> -->
<!-- <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Buy Yes: <input bind:value={yesAmountToBuy} />
          <button
            class="demo-button"
            on:click={() => buyYes(market.id, yesAmountToBuy)}>Buy Yes</button
          >
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Buy No: <input bind:value={noAmountToBuy} />
          <button
            class="demo-button"
            on:click={() => buyNo(market.id, noAmountToBuy)}
          >
            Buy No
          </button>
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Sell Yes: <input bind:value={yesAmountToSell} />
          <button
            class="demo-button"
            on:click={() => sellYes(market.id, yesAmountToSell)}
            >Sell Yes</button
          >
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Sell No: <input bind:value={noAmountToSell} />
          <button
            class="demo-button"
            on:click={() => sellNo(market.id, noAmountToSell)}
          >
            Sell No
          </button>
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Add Liquidity: <input bind:value={liquidityToAdd} />
          <button
            class="demo-button"
            on:click={() => addLiquidity(market.id, liquidityToAdd)}
          >
            Add liquidity
          </button>
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          <button
            class="demo-button"
            on:click={() => removeLiquidity(market.id)}
          >
            Remove Liquidity
          </button>
        </div> -->

<div
  style="display:flex; float:left; flex-direction: column; margin: 2em; background-color: pink; border-radius: 30px; padding: 1em;"
>
  <div style="">
    <h6 style="">Create new market</h6>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>Title:</div>
    <div><input bind:value={newMarketTitle} /></div>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>Description:</div>
    <div><textarea bind:value={newMarketDesc} /></div>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>Yes deposit:</div>
    <div>$<input bind:value={yesDeposit} /></div>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>No deposit:</div>
    <div>$<input bind:value={noDeposit} /></div>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>End date:</div>
    <div><input bind:value={endDate} /></div>
  </div>

  <button class="demo-button" on:click={createMarket}>Create Market</button>
</div>
<div>
  <button class="demo-button" on:click={deleteMarkets}> Delete Markets </button>
</div>
<div>
  <button class="demo-button" on:click={deleteUsers}>Delete Users</button>
</div>



// } else if (path.startsWith("/top")) {
    //   page = +path.slice(5)
    //   item = null
    // } else {
    //   window.location.hash = "/top/1"
    // }




    .App-logo {
    height: 15vmin;
    pointer-events: none;
  }

  .App-header {
    margin-top: 150px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: calc(10px + 2vmin);
  }

  .App-link {
    color: rgb(26, 117, 255);
  }

  .demo-button {
    background: #a02480;
    padding: 0 1.3em;
    margin-top: 1em;
    border-radius: 60px;
    font-size: 0.7em;
    height: 35px;
    outline: 0;
    border: 0;
    cursor: pointer;
    color: white;
  }

  .demo-button:active {
    color: white;
    background: #979799;
  }