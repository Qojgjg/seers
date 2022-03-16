<script>
  import Header from "./Header.svelte"

  export let auth

  let marketCreated = false
  let newMarketTitle
  let newMarketDesc
  let yesDeposit
  let noDeposit
  let endDate
  let imageUrl

  let createMarket = async () => {
    yesDeposit = parseInt(yesDeposit)
    noDeposit = parseInt(noDeposit)
    const liquidity = yesDeposit + noDeposit
    const yesProb = Math.floor((yesDeposit * 100) / liquidity)
    const noProb = 100 - yesProb
    const marketInitData = {
      title: newMarketTitle,
      description: newMarketDesc,
      yesProb: yesProb,
      noProb: noProb,
      liquidity: liquidity,
      endDate: Date.parse(endDate) * 1_000_000,
      imageUrl: imageUrl,
    }
    await $auth.actor.createMarket(marketInitData)
    marketCreated = true
  }
</script>

<Header />

{#if marketCreated}
  <div class="CreateBody">Market created!</div>
{:else}
  <div class="CreateBody">
    <div class="FormItem">
      <div style="">
        <h4 style="">Create New Market</h4>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Title:</div>
        <div>
          <input bind:value={newMarketTitle} size="80" maxlength="200" />
        </div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Description:</div>
        <div><textarea bind:value={newMarketDesc} rows="20" cols="70" /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Image URL:</div>
        <div><input bind:value={imageUrl} size="80" maxlength="200" /></div>
      </div>

      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Yes deposit:</div>
        <div><input bind:value={yesDeposit} size="20" maxlength="7" /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">No deposit:</div>
        <div><input bind:value={noDeposit} size="20" maxlength="7" /></div>
      </div>
      <div style="padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">End date:</div>
        <div><input bind:value={endDate} size="20" maxlength="10" /></div>
      </div>
      <button class="demo-button" on:click={createMarket}>Create Market</button>
    </div>
  </div>
{/if}

<style global>
  .CreateBody {
    display: flex;
    justify-content: center;
    width: 100%;
  }

  .FormItem {
    min-width: 400px;
    padding: 20px;
    border-radius: 10px;
    background: rgb(220 218 224 / 10%);
  }
</style>
