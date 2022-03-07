<script lang="ts">
  import { onMount, beforeUpdate } from "svelte"
  import { identity, select_multiple_value } from "svelte/internal"
  import Header from "./Header.svelte"

  export let auth
  export let marketId

  let market

  let action = "none" // none, trade, addLiquidity, removeLiquidity
  let seerAmount
  let addLiquidityAmount
  let removeLiquidityAmount
  let buyTokens = true
  let tokenIsYes = true

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(marketId))
    market = market[0]
    console.log(market)
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
    // markets = await $auth.actor.readAllMarkets()
  }

  onMount(readMarket)
</script>

<Header />
<div class="MarketDetails">
  {#if market}
    <div class="MarketHeader">
      <div class="MarketImage">
        <img class="Image" src={market.imageUrl} alt="random" />
      </div>
      <div class="MarketTitleDesc">
        <h3>{market.title}</h3>
        <p>{market.description}</p>
      </div>
      <div class="MarketControl">
        <button
          class={action === "trade" ? "menu-button-selected" : "menu-button"}
          on:click={() => {
            action = "trade"
          }}>Trade</button
        >
        <button
          class={action === "addLiquidity"
            ? "menu-button-selected"
            : "menu-button"}
          on:click={() => {
            action = "addLiquidity"
          }}>Add Liquidity</button
        >
        <button
          class={action === "removeLiquidity"
            ? "menu-button-selected"
            : "menu-button"}
          on:click={() => {
            action = "removeLiquidity"
          }}>Remove Liquidity</button
        >
        <hr style="width: 100%; border-color: black" />
        {#if action == "removeLiquidity"}
          Remove all liquidity.
          <button
            class="demo-button"
            on:click={() => {
              $auth.actor.removeLiquidity(market.id)
            }}>Remove</button
          >
        {:else if action == "addLiquidity"}
          <div>
            Add liquidity with seers tokens.
            <input bind:value={addLiquidityAmount} />
            <button
              class="demo-button"
              on:click={() => {
                $auth.actor.addLiquidity(market.id, addLiquidityAmount)
              }}>Add</button
            >
          </div>
        {:else if action == "trade"}
          Pick action:
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
              <input bind:value={seerAmount} />
            </div>
            <div class="ControlData">
              <div>LP fee 0.30%</div>
              <div>Avg. price $1 seers</div>
              <div>Max. winnings $4000 seers</div>
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
        {/if}
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
    width: 100%;
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
  .MarketImage {
    padding: 1em;
    background: rgb(220 218 224 / 25%);
  }
  .MarketControl {
    background: rgb(220 218 224 / 25%);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    padding: 2em;
    width: 200px;
    height: fit-content;
  }
  .MarketTitleDesc {
    padding: 2em;
    width: 400px;
    background: rgb(220 218 224 / 25%);
    justify-content: flex-start;
    align-items: flex-start;
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
