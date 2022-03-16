<script lang="ts">
  import { onMount, beforeUpdate } from "svelte"
  import { identity, select_multiple_value } from "svelte/internal"
  import Header from "./Header.svelte"

  export let auth
  export let marketId

  let market

  let seerAmount = 0
  let addLiquidityAmount
  let removeLiquidityAmount
  let buyTokens = true
  let tokenIsYes = true
  let tokensEstimate

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(marketId))
    market = market[0]
    console.log(market)
  }

  const dryRun = async (marketId, amount) => {
    amount = parseInt(amount)
    if (buyTokens && tokenIsYes) {
      // buy yes
      tokensEstimate = await $auth.actor.buyYes(marketId, amount, false)
    } else if (buyTokens && !tokenIsYes) {
      // buy no
      tokensEstimate = await $auth.actor.buyNo(marketId, amount, false)
    }
    // else if (!buyTokens && tokenIsYes) {
    //   // sell yes
    //   tokensEstimate = await $auth.actor.sellYes(marketId, amount, false)
    // } else if (!buyTokens && !tokenIsYes) {
    //   // sell no
    //   tokensEstimate = await $auth.actor.sellNo(marketId, amount, false)
    // }
    console.log("tokens estimate: " + tokensEstimate)
  }

  const doIt = async (marketId, amount) => {
    amount = parseInt(amount)
    if (buyTokens && tokenIsYes) {
      // buy yes
      await $auth.actor.buyYes(marketId, amount, true)
    } else if (buyTokens && !tokenIsYes) {
      // buy no
      await $auth.actor.buyNo(marketId, amount, true)
    } else if (!buyTokens && tokenIsYes) {
      // sell yes
      await $auth.actor.sellYes(marketId, amount, true)
    } else if (!buyTokens && !tokenIsYes) {
      // sell no
      await $auth.actor.sellNo(marketId, amount, true)
    }
  }

  onMount(readMarket)
</script>

<Header />

<div class="container">
  {#if market}
    <div class="market">
      <div style="width:100%; line-height: 1.6;">
        <h3>{market.title}</h3>
        <img class="Image" src={market.imageUrl} alt="random" />
        {market.description}
      </div>
    </div>
    <div class="v-container">
      <div class="market-controls">
        <ul style="list-style-type: none; margin: 0; padding: 0">
          <li>State: {Object.keys(market.state)}</li>
          <li>
            Start date: {new Date(
              parseInt(market.startDate) / 1_000_000,
            ).toLocaleDateString()}
          </li>
          <li>
            End date: {new Date(
              parseInt(market.endDate) / 1_000_000,
            ).toLocaleDateString()}
          </li>
          <li>Liquidity: {market.liquidity} S</li>
          <li>Volume: {market.volume} S</li>
        </ul>
      </div>
      <div class="market-controls">
        <div
          style="display:flex; justify-content:start; text-align:center; align-items:center;flex-direction:column"
        >
          <button
            class="demo-button"
            on:click={() => {
              $auth.actor.removeLiquidity(market.id)
            }}>Remove All Liquidity Provided</button
          >
          <div>
            <input bind:value={addLiquidityAmount} />
            <button
              class="demo-button"
              on:click={() => {
                $auth.actor.addLiquidity(market.id, addLiquidityAmount)
              }}>Add Liquidity</button
            >
          </div>

          Trade:
          <div class="YesNoOptions">
            <button
              class="BuyOpt"
              on:click={() => {
                buyTokens = true
              }}>Buy</button
            >
            <button
              class="SellOpt"
              on:click={() => {
                buyTokens = false
              }}>Sell</button
            >
          </div>
          Pick Outcome:
          <div class="ContentTab">
            <div class="YesNoOptions">
              <button
                class="BuyOpt"
                on:click={() => {
                  tokenIsYes = true
                }}>Yes ${parseInt(market.yesProb) / 100.0}</button
              >
              <button
                class="SellOpt"
                on:click={() => {
                  tokenIsYes = false
                }}>No ${parseInt(market.noProb) / 100.0}</button
              >
            </div>
            <div class="OutcomeTitle">Amount:</div>
            <div class="OutcomeTitle">
              <input
                bind:value={seerAmount}
                on:change={() => dryRun(market.id, seerAmount)}
              />
            </div>
            <div class="ControlData">
              <div>LP fee 0.00%</div>
              <div>
                Avg. price {(seerAmount / tokensEstimate).toFixed(2)} seers
              </div>
              <div>Max. winnings {tokensEstimate - seerAmount} seers</div>
            </div>
            <button
              class="demo-button"
              on:click={() => doIt(market.id, seerAmount)}
            >
              {#if buyTokens}
                {#if tokenIsYes}
                  Buy Yes
                {:else}
                  Buy No
                {/if}
              {:else if tokenIsYes}
                Sell Yes
              {:else}
                Sell No
              {/if}
            </button>
          </div>
        </div>
      </div>
    </div>
  {:else}
    Loading
  {/if}
</div>

<style global>
  .menu-button {
    color: white;
    background: rgb(220 218 224 / 25%);
    padding: 5px;
    margin: 3px 0px;
    border-radius: 5px;
    font-size: 1em;
    height: 33px;
    border: 0;
    align-items: center;
    text-align: center;
    border-color: white;
    cursor: pointer;
    text-decoration: none;
  }

  .menu-button-selected {
    color: white;
    background: rgba(12, 3, 43, 0.9);
    padding: 5px;
    margin: 3px 0px;
    border-radius: 5px;
    font-size: 1em;
    height: 33px;
    border: 0;
    align-items: center;
    text-align: center;
    border-color: white;
    cursor: pointer;
    text-decoration: none;
  }

  .Image {
    border-radius: 8px;
    width: 200px;
    float: left;
    margin: 10px;
  }

  .ControlData {
    margin-top: 0.5em;
  }

  .OutcomeTitle {
    width: 100%;
    margin-top: 0.5em;
  }
  .YesNoOptions {
    width: 100%;
    display: flex;
    margin-top: 0.5em;
    height: fit-content;
  }
  .TabOptions {
    width: 100%;
    display: flex;
    margin-top: 0.5em;
    height: fit-content;
  }
  .ContentTab {
    width: 100%;
  }
  .BuyOpt {
    width: 50%;
    height: fit-content;
  }
  .SellOpt {
    width: 50%;
    height: fit-content;
  }
  .BuyTab {
    width: 50%;
    height: fit-content;
  }
  .SellTab {
    width: 50%;
    height: fit-content;
  }
  .container {
    display: flex;
    justify-content: center;
  }
  .v-container {
    display: flex;
    flex-direction: column;
    justify-content: start;
  }
  .market {
    padding: 2em;
    background: rgb(220 218 224 / 10%);
    min-height: 500px;
    width: 50%;
    margin: 0em 1em;
    border-radius: 1em;
    word-wrap: break-word;
    overflow: auto;
    display: flex;
    justify-content: center;
  }

  .market-controls {
    margin-bottom: 1em;
    padding: 1em;
    background: rgb(220 218 224 / 10%);
    height: fit-content;
    border-radius: 1em;
    word-wrap: break-word;
    overflow: auto;
    display: flex;
    justify-content: center;
  }
  .MarketDetails {
    display: flex;
    justify-content: center;
    align-items: flex-start;
  }

  .MarketHeader {
    display: flex;
    align-items: flex-start;
    justify-content: flex-start;
    text-align: start;
  }

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
    background: black;
    padding: 0 1em;
    margin-top: 1em;
    border-radius: 10px;
    font-size: 0.9em;
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
