<script>
  export let auth

  let marketCreated = false
  let newMarketTitle = "Champions League: Benfica vs Liverpool."
  let newMarketDesc = "Who will win?"
  let endDate = "10/10/2022"
  let imageUrl = "https://"

  let createMarket = async () => {
    const liquidity = 3000
    const marketInitData = {
      title: newMarketTitle,
      description: newMarketDesc,
      labels: ["Benfica", "Liverpool", "Draw"],
      probabilities: [333, 333, 333],
      liquidity: liquidity,
      endDate: Date.parse(endDate) * 1_000_000,
      imageUrl: imageUrl,
    }
    await $auth.actor.createMarket(marketInitData)
    marketCreated = true
  }
</script>

<div class="header">
  <h3>Create Market</h3>
</div>
{#if marketCreated}
  <div class="row">Market created!</div>
{:else}
  <div class="row">
    <div class="form">
      <div style="width: 80%; padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Title:</div>
        <div>
          <input bind:value={newMarketTitle} size="40" maxlength="200" />
        </div>
      </div>
      <div style="width: 80%; padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Description:</div>
        <div><textarea bind:value={newMarketDesc} rows="20" cols="40" /></div>
      </div>
      <div style="width: 80%;padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Image URL:</div>
        <div><input bind:value={imageUrl} size="40" maxlength="200" /></div>
      </div>

      <!-- <div style="width: 80%;padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Yes deposit:</div>
        <div><input bind:value={yesDeposit} size="20" maxlength="7" /></div>
      </div>
      <div style="width: 80%;padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">No deposit:</div>
        <div><input bind:value={noDeposit} size="20" maxlength="7" /></div>
      </div> -->
      <div style="width: 80%;padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">End date:</div>
        <div><input bind:value={endDate} size="20" maxlength="10" /></div>
      </div>
      <div style="width: 100%;text-align:center; ">
        <button class="demo-button" on:click={createMarket}
          >Create Market</button
        >
      </div>
    </div>
  </div>
{/if}

<style global>
  .header {
    text-align: center;
    padding-top: 60px;
  }

  .row {
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    padding: 0 4px;
    justify-content: center;
    align-items: center;
    align-content: center;
  }

  .form {
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    padding: 10px;
    justify-content: center;
    border-radius: 5px;
    background: rgb(220 218 224 / 10%);
  }
</style>
