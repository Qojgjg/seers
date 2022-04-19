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

  let errorResponse = ""

  let buyOptClass = "BuyOptSelected"
  let sellOptClass = "SellOpt"

  let buttonLabel = "Submit"
  let selectedLabel = ""

  let selected
  let probabilities = [0.6, 0.4]

  let buyTokens = true

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
      <h4>Forecast</h4>
      <div
        style="width: 100%; text-align: center; display: flex; flex-direction: column; justify-content: center"
      >
        {#if principal !== ""}
          {#each market.labels as label}
            <div
              style="display:flex; flex-direction:row; width: 100%; justify-content:center; align-items:center; padding: 5px"
            >
              <div style="width: 50px;">{label}</div>
              <div style="width: 50px;">
                <input
                  style="width: 100%; background:gray; height: 1em;"
                  placeholder="0.0"
                /> %
              </div>
            </div>
          {/each}
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

<style>
  input,
  select,
  textarea {
    font-size: 1.5em;
    color: black;
  }

  textarea:focus,
  input:focus {
    font-size: 1.5em;
    color: black;
  }
</style>
