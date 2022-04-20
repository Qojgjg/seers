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
  let buttonLabel = "Submit"
  let selectedLabel = ""

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
</script>

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
                style="width: 100%; color: rgb(255, 255, 255); background-color: rgb(33, 36, 41); height: 1em; font-family: 'Roboto Mono', monospace; border: 0"
                placeholder="0"
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

<style>
  input {
    font-size: 1.5em;
    color: black;
  }

  input:focus {
    font-size: 1.5em;
    color: black;
  }
</style>
