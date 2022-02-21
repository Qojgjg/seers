<script lang="ts">
  import logo from "./assets/logo-dark.svg"
  import { onMount } from "svelte"

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

  const refreshMarkets = async () => {
    ms = await $auth.actor.readAllMarkets()
  }

  const deleteMarkets = async () => {
    await $auth.actor.deleteAllMarkets()
  }

  const removeLiquidity = async () => {}
  const addLiquidity = async () => {}
  const buyYes = async () => {}
  const buyNo = async () => {}

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
  <p style="font-size: 2em; margin-bottom: 0.5em">Seer</p>
  <div>
    <code>Prediction Markets</code>
    <p>Canister ID: {process.env.MARKETS_CANISTER_ID}</p>
  </div>
  <div style="display: flex; flex-wrap: wrap; padding: 0 4px;">
    {#each ms as market}
      <div
        style="min-width: 30%;  font-size: 0.7em;  padding: 2em; margin: 2em; border-radius: 30px;  background: rgb(220 218 224 / 25%);"
      >
        <div><img src="https://picsum.photos/100" alt="random" /></div>
        <div>
          #{market.id}
          <h3>{market.title}</h3>
        </div>
        <div>{market.description}</div>
        <div>Yes: {market.yesProb}%</div>
        <div>No: {market.noProb}%</div>
        <div>Liquidity: {market.liquidity}</div>
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
        <div>Author: {market.author}</div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Buy Yes: <input bind:value={yesAmountToBuy} />
          <button class="demo-button" on:click={buyYes}>Buy Yes</button>
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Buy No: <input bind:value={noAmountToBuy} />
          <button class="demo-button" on:click={buyNo}> Buy No </button>
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          Add Liquidity: <input bind:value={liquidityToAdd} />
          <button class="demo-button" on:click={addLiquidity}>
            Add liquidity
          </button>
        </div>
        <div style="padding: 1em; text-align:left; font-size: 0.8em">
          <button class="demo-button" on:click={addLiquidity}>
            Remove Liquidity
          </button>
        </div>
      </div>
    {/each}
  </div>
  <div
    style="display:flex; float:left; flex-direction: column; margin: 2em; background-color: pink; border-radius: 30px; padding: 1em;"
  >
    <div style="padding: 0.1em;"><h4 style="">Create new market</h4></div>
    <div style="padding: 1em; text-align:left; font-size: 0.8em">
      Title: <input bind:value={newMarketTitle} />
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.8em">
      Description: <input bind:value={newMarketDesc} />
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.8em">
      Yes deposit: <input bind:value={yesDeposit} />
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.8em">
      No deposit: <input bind:value={noDeposit} />
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.8em">
      End date: <input bind:value={endDate} />
    </div>

    <button class="demo-button" on:click={createMarket}> Create Market </button>
  </div>
  <button class="demo-button" on:click={deleteMarkets}> Delete Markets </button>
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
