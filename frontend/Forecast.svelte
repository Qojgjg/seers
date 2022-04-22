<script lang="ts">
  let id
  let startDate
  let endDate
  let volume
  let liquidity
  let state = { open: null }
  let labels = ["Yes", "No"]
  let principal

  let errorResponse = ""

  let probabilities = [0.6, 0.4]

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
    style="display:flex; justify-content:start; text-align:center; align-items:center;flex-direction:column;width: 200px; padding: 10px;"
  >
    <h4>Forecast</h4>
    <div
      style="width: 200px; text-align: center; display: flex; flex-direction: column; justify-content: center"
    >
      {#if principal !== ""}
        {#each market.labels as label}
          <div
            style="display:flex; flex-direction:row; width: 200px; justify-content:center; align-items:center; padding: 5px"
          >
            <div style="width: 50px; margin-right: 20px">{label}</div>
            <div style="width: 50px;">
              <input
                style="width: 100%; color: rgb(255, 255, 255); background-color: rgb(33, 36, 41); height: 1em; font-family: 'Roboto Mono', monospace; border: 0"
                placeholder="0"
              /> %
            </div>
          </div>
        {/each}
        <div
          style="width: 200px; justify-content: center; text-align: center; display: flex"
        >
          <button class="btn-grad" on:click={() => 0}> Submit </button>
        </div>
        <div style="width: 100%;text-align:center;color:red">
          {errorResponse}
        </div>
      {:else}
        <div
          style="width: 200px; justify-content: center; text-align: center; display: flex"
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
