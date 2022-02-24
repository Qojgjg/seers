<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount } from "svelte"
  import { identity } from "svelte/internal"

  export let auth

  let ms: any = []
  let newMarketTitle: any = ""
  let newMarketDesc: any = ""
  let yesDeposit: any = ""
  let noDeposit: any = ""
  let endDate: any = ""
  let liquidityToAdd: any = ""
  let yesAmountToBuy: any = ""
  let noAmountToBuy: any = ""
  let yesAmountToSell: any = ""
  let noAmountToSell: any = ""

  const refreshMarkets = async () => {
    ms = await $auth.actor.readAllMarkets()
  }

  const deleteMarkets = async () => {
    await $auth.actor.deleteAllMarkets()
    refreshMarkets()
  }

  const deleteUsers = async () => {
    await $auth.actor.deleteAllUsers()
    refreshMarkets()
  }

  const removeLiquidity = async (marketId) => {
    console.log("Removing liquidity to market " + marketId)
    await $auth.actor.removeLiquidity(marketId)
    refreshMarkets()
  }

  const addLiquidity = async (marketId, value) => {
    console.log("Adding liquidity to market " + marketId)
    await $auth.actor.addLiquidity(marketId, parseInt(value))
    refreshMarkets()
  }

  const buyYes = async (marketId, value) => {
    console.log(
      "Buying Yes tokens from market " + marketId + " value " + parseInt(value),
    )
    const tokens = await $auth.actor.buyYes(marketId, parseInt(value))
    console.log(tokens)
    refreshMarkets()
  }

  const buyNo = async (marketId, value) => {
    console.log(
      "Buying No tokens from market " + marketId + " value " + parseInt(value),
    )
    const tokens = await $auth.actor.buyNo(marketId, parseInt(value))
    console.log(tokens)
    refreshMarkets()
  }

  const sellYes = async (marketId, value) => {
    console.log(
      "Selling Yes tokens from market " +
        marketId +
        " value " +
        parseInt(value),
    )
    const tokens = await $auth.actor.sellYes(marketId, parseInt(value))
    console.log(tokens)
    refreshMarkets()
  }

  const sellNo = async (marketId, value) => {
    console.log(
      "Selling No tokens from market " + marketId + " value " + parseInt(value),
    )
    const tokens = await $auth.actor.sellNo(marketId, parseInt(value))
    console.log(tokens)
    refreshMarkets()
  }

  const createMarket = async () => {
    yesDeposit = parseInt(yesDeposit, 10)
    noDeposit = parseInt(noDeposit, 10)

    const totalDeposit = yesDeposit + noDeposit
    const yesProb = (yesDeposit / totalDeposit) * 100.0
    const noProb = (noDeposit / totalDeposit) * 100.0

    endDate = Date.parse(endDate) * 1_000_000

    const market: any = {
      title: newMarketTitle,
      description: newMarketDesc,
      yesProb: Math.floor(yesProb + 0.5),
      noProb: Math.floor(noProb + 0.5),
      liquidity: totalDeposit,
      endDate: endDate,
    }

    newMarketDesc = ""
    newMarketTitle = ""
    yesDeposit = ""
    noDeposit = ""
    endDate = ""

    await $auth.actor.createMarket(market)
    refreshMarkets()
  }

  onMount(refreshMarkets)
</script>

<header class="App-header">
  <p style="font-size: 2em; margin-bottom: 0.5em">Seers</p>
  <div>
    <code>Prediction Markets</code>
    <p>Canister ID: {process.env.MARKETS_CANISTER_ID}</p>
  </div>
  <div style="display: flex; flex-wrap: wrap; padding: 0 4px;">
    {#each ms as market}
      <div
        style="width: 160px; font-size: 0.7em;  padding: 2em; margin: 2em; border-radius: 30px;  background: rgb(220 218 224 / 25%);"
      >
        <div><img src="https://picsum.photos/100" alt="random" /></div>
        <div>
          <!-- #{market.id} -->
          <h3>{market.title}</h3>
        </div>
        <!-- <div>{market.description}</div> -->
        <div>Yes: {market.yesProb}%</div>
        <div>No: {market.noProb}%</div>
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
      </div>
    {/each}
  </div>
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
    <button class="demo-button" on:click={deleteMarkets}>
      Delete Markets
    </button>
  </div>
  <div>
    <button class="demo-button" on:click={deleteUsers}>Delete Users</button>
  </div>
</header>

<style global>
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
</style>
