<script lang="ts">
  import { NullClass } from "@dfinity/candid/lib/cjs/idl"

  import { concat } from "@dfinity/candid/lib/cjs/utils/buffer"
  import { faImages } from "@fortawesome/free-solid-svg-icons"
  import { onMount, beforeUpdate } from "svelte"
  import { identity, select_multiple_value } from "svelte/internal"

  export let auth
  export let marketId
  export let signedIn

  let market

  let seerAmount = 0
  let selected = 0
  let selectedLabel
  let buyOptClass = "BuyOptSelected"
  let sellOptClass = "SellOpt"
  let buyTokens = true
  let buttonLabel
  let tokensEstimate = 0.0
  let response = null
  let errorResponse = ""

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(marketId))
    market = market[0]
    selectedLabel = market.labels[0]
    selected = 0
    buttonLabel = "Buy " + selectedLabel
    console.log(market)
  }

  const dryRun = async (marketId, amount) => {
    amount = parseInt(amount)
    console.log("Selected: " + selected)
    if (buyTokens) {
      response = await $auth.actor.buyOption(marketId, amount, selected, false)
    } else {
      response = await $auth.actor.sellOption(marketId, amount, selected, false)
    }

    if (response["err"]) {
      errorResponse =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      errorResponse = ""
      tokensEstimate = response["ok"]
    }
  }

  const doIt = async (marketId, amount) => {
    errorResponse = ""
    buttonLabel = "Processing..."
    amount = parseInt(amount)
    console.log("Selected: " + selected)

    if (buyTokens) {
      response = await $auth.actor.buyOption(marketId, amount, selected, true)
    } else {
      response = await $auth.actor.sellOption(marketId, amount, selected, true)
    }
    if (response["err"]) {
      errorResponse =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      errorResponse = ""
      tokensEstimate = response["ok"]
    }
    if (buyTokens) buttonLabel = "Buy " + selectedLabel
    else buttonLabel = "Sell " + selectedLabel

    readMarket()
  }

  onMount(readMarket)
</script>

{#if market}
  <div class="header">
    <h3>{market.title}</h3>
  </div>
  <div class="rowView">
    <div class="market">
      <!-- <h3 style="margin:5px; padding: 5px; text-align:center">Description</h3> -->
      {#if market.imageUrl}
        <img class="Image" src={market.imageUrl} alt="random" />
      {/if}
      <div style="line-height: 1.6;">
        {market.description}
      </div>
    </div>
    <div class="v-container">
      <div class="market-controls">
        <ul
          style="list-style-type: none; margin: 0; padding: 10px; width: 100%; line-height: 1.5em"
        >
          <h4 style="text-align:center; padding: 3px; margin: 3px">Details</h4>

          <li>Status: {Object.keys(market.state).toString()}</li>
          <!-- <li>
            Starts: {new Date(
              parseInt(market.startDate) / 1_000_000,
            ).toDateString()}
          </li> -->
          <li>
            Ends: {new Date(
              parseInt(market.endDate) / 1_000_000,
            ).toDateString()}
          </li>
          <li>Volume: {market.volume} &Sigma;</li>
          <li>
            Liquidity: {market.liquidity} &Sigma;
          </li>
        </ul>
      </div>
      <div class="market-controls">
        <div
          style="display:flex; justify-content:start; text-align:center; align-items:center;flex-direction:column;width: 100%; padding: 10px;"
        >
          <h4>Trade</h4>
          <div class="YesNoOptions">
            <button
              class={buyOptClass}
              on:click={() => {
                buyOptClass = "BuyOptSelected"
                sellOptClass = "SellOpt"
                buyTokens = true
                buttonLabel = "Buy " + selectedLabel
              }}>Buy</button
            >
            <button
              class={sellOptClass}
              on:click={() => {
                buyOptClass = "BuyOpt"
                sellOptClass = "SellOptSelected"
                buyTokens = false
                buttonLabel = "Sell " + selectedLabel
              }}>Sell</button
            >
          </div>
          <div class="OutcomeTitle">Pick Outcome:</div>
          <!-- {#if market.images[selected]}
            <img
              class="Image"
              src={market.images[selected]}
              alt="image of {selectedLabel}"
            />
          {/if} -->

          <div class="ContentTab">
            <select
              bind:value={selected}
              style="width: 100%"
              on:change={() => {
                selectedLabel = market.labels[selected]
                if (buyTokens) buttonLabel = "Buy " + selectedLabel
                else buttonLabel = "Sell " + selectedLabel
              }}
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
                on:input={() => dryRun(market.id, seerAmount)}
                style="width:100%; height: 30px"
              />
            </div>
            <div class="ControlData">
              <div>LP fee 0.00%</div>
              <div>
                {#if buyTokens}
                  Avg. price {tokensEstimate
                    ? (seerAmount / tokensEstimate).toFixed(2)
                    : 0} &Sigma;
                {:else}
                  Avg. price {tokensEstimate
                    ? (seerAmount / tokensEstimate).toFixed(2)
                    : 0} tokens
                {/if}
              </div>
              <div>
                {#if buyTokens}
                  Max. Winnings {tokensEstimate
                    ? Number(tokensEstimate).toFixed(2)
                    : Number(0).toFixed(2)}
                  &Sigma;
                {:else}
                  Get back {tokensEstimate
                    ? Number(tokensEstimate).toFixed(2)
                    : Number(0).toFixed(2)} &Sigma;
                {/if}
              </div>
            </div>
            {#if signedIn}
              <button
                class="demo-button"
                on:click={() => doIt(market.id, seerAmount)}
              >
                {buttonLabel}
              </button>
              <div style="width: 100%;text-align:center;color:red">
                {errorResponse}
              </div>
            {:else}
              <button class="demo-button" disabled> Please login </button>
            {/if}
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
    height: 30px;
  }
  .header {
    display: flex;
    text-align: center;
    justify-content: center;
    padding-top: 60px;
    width: 100%;
  }

  .rowView {
    display: flex;
    flex-wrap: wrap;
    padding-top: 40px;
    justify-content: center;
    width: 100%;
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
    padding: 0px 10px 10px 0px;
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
    height: 30px;
    color: white;
    border-radius: 5px 0 0 5px;
    background: rgb(220 218 224 / 25%);
  }
  .SellOpt {
    width: 50%;
    height: 30px;
    color: white;
    border-radius: 0 5px 5px 0;
    background: rgb(220 218 224 / 25%);
  }
  .BuyOptSelected {
    width: 50%;
    height: 30px;
    color: black;
    border-radius: 5px 0 0 5px;
  }
  .SellOptSelected {
    width: 50%;
    height: 30px;
    border-radius: 0 5px 5px 0;
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

    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    color: rgb(255, 255, 255);
    justify-content: space-between;
    font-family: "Inter", sans-serif;
    margin: 0em 1em;
    word-wrap: break-word;
    overflow: auto;
    flex-direction: column;
    height: fit-content;
    min-width: 400px;
    max-width: 40%;
    margin-bottom: 1em;
  }

  @media only screen and (max-width: 600px) {
    .market {
      margin: 1em;
      display: flex;
      flex-direction: column;
      justify-content: center;
      width: 300px;
      min-width: 0px;
      max-width: 80%;
    }

    .market-controls {
      margin: 1em;
      width: 300px;
    }
  }

  .market-controls {
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);
    margin-bottom: 1em;
    padding: 0.5em;
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    justify-content: space-between;
    font-family: "Inter", sans-serif;
    font-size: 1rem;
    font-weight: 500;
    word-break: break-word;
    overflow: hidden;
    white-space: nowrap;
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
