<script lang="ts">
  import { concat } from "@dfinity/candid/lib/cjs/utils/buffer"
  import { faImages } from "@fortawesome/free-solid-svg-icons"
  import { onMount, beforeUpdate } from "svelte"
  import { identity, select_multiple_value } from "svelte/internal"

  export let auth
  export let marketId

  let market

  let seerAmount = 0
  let selected = 0
  let selectedLabel
  let buyOptClass = "BuyOptSelected"
  let sellOptClass = "SellOpt"
  let buyTokens = true
  let tokenIsYes = true
  let tokensEstimate

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(marketId))
    market = market[0]
    selectedLabel = market.labels[0]
    console.log(market)
  }

  const dryRun = async (marketId, amount) => {
    amount = parseInt(amount)
    if (buyTokens) {
      tokensEstimate = await $auth.actor.buyOption(
        marketId,
        amount,
        selected,
        false,
      )
    } else {
      tokensEstimate = await $auth.actor.sellOption(
        marketId,
        amount,
        selected,
        false,
      )
    }
    console.log("tokens estimate: " + tokensEstimate)
  }

  const doIt = async (marketId, amount) => {
    amount = parseInt(amount)
    if (buyTokens) {
      await $auth.actor.buyOption(marketId, amount, selected, true)
    } else {
      await $auth.actor.sellOption(marketId, amount, selected, true)
    }
  }

  onMount(readMarket)
</script>

{#if market}
  <div class="header">
    <h3>{market.title}</h3>
  </div>
  <div class="rowView">
    <div class="market">
      {#if market.imageUrl}
        <img class="Image" src={market.imageUrl} alt="random" />
      {/if}
      <div style="line-height: 1.6;">
        {market.description}
      </div>
    </div>
    <div class="v-container">
      <div class="market-controls">
        <ul style="list-style-type: none; margin: 0; padding: 0">
          <h4>Details</h4>

          <li>State: {Object.keys(market.state).toString()}</li>
          <li>
            Starts: {new Date(
              parseInt(market.startDate) / 1_000_000,
            ).toLocaleDateString()}
          </li>
          <li>
            Ends: {new Date(
              parseInt(market.endDate) / 1_000_000,
            ).toLocaleDateString()}
          </li>
          <li>Liquidity: {market.liquidity} &Sigma;</li>
          <li>Volume: {market.volume} &Sigma;</li>
        </ul>
      </div>
      <div class="market-controls">
        <div
          style="display:flex; justify-content:start; text-align:center; align-items:center;flex-direction:column"
        >
          <h4>Trade</h4>
          <div class="YesNoOptions">
            <button
              class={buyOptClass}
              on:click={() => {
                buyOptClass = "BuyOptSelected"
                sellOptClass = "SellOpt"
                buyTokens = true
              }}>Buy</button
            >
            <button
              class={sellOptClass}
              on:click={() => {
                buyOptClass = "BuyOpt"
                sellOptClass = "SellOptSelected"
                buyTokens = false
              }}>Sell</button
            >
          </div>
          <div style="padding: 5px">Pick Outcome:</div>
          {#if market.images[selected]}
            <img
              class="Image"
              src={market.images[selected]}
              alt="image of {selectedLabel}"
            />
          {/if}

          <div class="ContentTab">
            <select
              bind:value={selected}
              style="width: 100%"
              on:change={() => (selectedLabel = market.labels[selected])}
            >
              {#each market.labels as label, i}
                <option value={i}>
                  {(Number(market.probabilities[i]) / 1000.0).toFixed(2)} &Sigma;
                  - {label}
                </option>
              {/each}
            </select>
            <div class="OutcomeTitle">Amount:</div>
            <div class="OutcomeTitle">
              <input
                bind:value={seerAmount}
                on:change={() => dryRun(market.id, seerAmount)}
                style="width:100%"
              />
            </div>
            <div class="ControlData">
              <div>LP fee 0.00%</div>
              <div>
                Avg. price {tokensEstimate
                  ? (seerAmount / tokensEstimate).toFixed(2)
                  : 0} &Sigma;
              </div>
              <div>
                Max. Winnings {tokensEstimate ? tokensEstimate : 0} &Sigma;
              </div>
            </div>
            <button
              class="demo-button"
              on:click={() => doIt(market.id, seerAmount)}
            >
              {#if buyTokens}
                Buy {selectedLabel}
              {:else}
                Sell {selectedLabel}
              {/if}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
{:else}
  <div class="header">Loading</div>
{/if}

<style global>
  select {
    background-color: white;
    color: black;
    border-color: white;
    margin-top: 10px;
  }
  .header {
    text-align: center;
    justify-content: center;
    padding-top: 60px;
    width: 100%;
  }

  .rowView {
    display: flex;
    flex-wrap: wrap;
    padding: 0 4px;
    justify-content: center;
  }

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

  button {
    border: none;
    padding: 3px;
  }

  .Image {
    border-radius: 8px;
    width: 150px;
    float: left;
    padding-right: 10px;
    padding-left: 10px;
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
    color: white;
    background: rgb(220 218 224 / 25%);
  }
  .SellOpt {
    width: 50%;
    height: fit-content;
    color: white;
    background: rgb(220 218 224 / 25%);
  }
  .BuyOptSelected {
    width: 50%;
    height: fit-content;
    color: black;
  }
  .SellOptSelected {
    width: 50%;
    height: fit-content;
    color: black;
  }
  .YesTabSelected {
    width: 50%;
    height: fit-content;
    color: white;
    background-color: green;
  }
  .NoTabSelected {
    width: 50%;
    height: fit-content;
    color: white;
    background-color: crimson;
  }
  .YesTab {
    width: 50%;
    height: fit-content;
    color: black;
  }
  .NoTab {
    width: 50%;
    height: fit-content;
    color: black;
  }
  .container {
    display: flex;
    justify-content: center;
  }
  .v-container {
    display: flex;
    flex-direction: column;
    justify-content: start;
    margin: 0em 1em;
  }
  .market {
    padding: 2em;
    /* background: rgb(33, 36, 41) !important; */
    /* uniswap style follows */
    background-color: rgb(25, 27, 31);
    border: 2px solid rgb(25, 27, 31);
    border-radius: 16px;
    color: rgb(255, 255, 255);
    justify-content: space-between;
    font-family: "Inter", sans-serif;

    /* padding: 6px 8px; */
    /* background: rgb(220 218 224 / 10%); */
    margin: 0em 1em;
    word-wrap: break-word;
    overflow: auto;
    flex-direction: column;
    /* justify-content: start; */
    height: fit-content;
    min-width: 400px;
    max-width: 40%;
    margin-bottom: 1em;
  }

  @media only screen and (max-width: 600px) {
    .market {
      padding: 2em;
      background: rgb(220 218 224 / 10%);
      margin: 0em 1em;
      border-radius: 1em;
      word-wrap: break-word;
      overflow: auto;
      display: flex;
      flex-direction: column;
      justify-content: center;
      max-width: 234px;
      margin-bottom: 1em;
    }
  }

  .market-controls {
    margin-bottom: 1em;
    padding: 1em;
    /* background: rgb(220 218 224 / 10%); */
    background-color: rgb(25, 27, 31);
    border: 2px solid rgb(25, 27, 31);
    border-radius: 16px;
    justify-content: space-between;
    font-family: "Inter", sans-serif;
    font-size: 1rem;
    font-weight: 500;
    /* padding: 8px 12px; */
    word-break: break-word;
    overflow: hidden;
    white-space: nowrap;

    /* line-height: 1.4em; */

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

  .tton {
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
    max-width: 200px;
  }
</style>
