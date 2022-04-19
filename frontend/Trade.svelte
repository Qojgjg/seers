<script lang="ts">
  import Content from "./Content.svelte"
  import Modal from "./Modal.svelte"
  import { modal } from "./store/stores.js"

  let id
  let startDate
  let endDate
  let volume
  let liquidity
  let state = { open: null }
  let tokensEstimate
  let seerAmount
  let labels = ["Yes", "No"]
  let principal

  let errorResponse

  let buyOptClass
  let sellOptClass

  let buttonLabel
  let selectedLabel

  let selected
  let probabilities = [0.6, 0.4]

  let buyTokens

  let market = {
    id,
    state,
    startDate,
    endDate,
    volume,
    liquidity,
    labels,
    probabilities,
  }

  let typingTimer //timer identifier

  const debounce = (id, a, ms) => {
    tokensEstimate = 0
    clearTimeout(typingTimer)
    if (seerAmount) {
      //   typingTimer = setTimeout(() => dryRun(id, a), ms)
    }
  }
</script>

<div class="v-container">
  <!-- <div class="market-controls">
    <ul
      style="list-style-type: none; margin: 0; padding: 10px; width: 100%; line-height: 1.5em"
    >
      <h4 style="text-align:center; padding: 3px; margin: 3px">Details</h4>

      <li>
        <div style="margin:0;padding:0;text-transform:capitalize">
          Status: {Object.keys(market.state).toString()}
        </div>
      </li>
      <li>
        Starts: {new Date(
          parseInt(market.startDate) / 1_000_000,
        ).toDateString()}
      </li>
      <li>
        Ends: {new Date(parseInt(market.endDate) / 1_000_000).toDateString()}
      </li>
      <li>Volume: {Number(market.volume).toFixed(2)} &Sigma;</li>
      <li>
        Liquidity: {Number(market.liquidity).toFixed(2)} &Sigma;
      </li>
    </ul>
  </div> -->
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
              {(Number(market.probabilities[i]) / 1000.0).toFixed(2)} &Sigma; - {label.slice(
                0,
                20,
              )}
            </option>
          {/each}
        </select>
        <div class="OutcomeTitle">Amount:</div>
        <div class="OutcomeTitle">
          <input
            bind:value={seerAmount}
            on:keyup={() => debounce(market.id, seerAmount, 500)}
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
        <div
          style="width: 100%; text-align: center; display: flex; flex-direction: column; justify-content: center"
        >
          {#if principal !== ""}
            <Modal show={$modal}>
              <Content
                onOk={() => {
                  let res = 0
                  //   doIt(market.id, seerAmount)
                  seerAmount = 0.0
                  tokensEstimate = 0.0
                  return res
                }}
                {tokensEstimate}
                {seerAmount}
                outcome={selectedLabel}
                {buttonLabel}
                {buyTokens}
              />
            </Modal>
            <div style="width: 100%;text-align:center;color:red">
              {errorResponse}
            </div>
          {:else}
            <div
              style="width: 100%; justify-content: center; text-align: center; display: flex"
            >
              <button class="btn-grad" on:click={() => 0}> Login </button>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
</div>
