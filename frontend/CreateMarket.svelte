<script>
  import Header from "./Header.svelte"

  export let auth

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
  }
</script>

<Header />

<div class="CreateBody">
  <div class="FormItem">
    <div style="">
      <h4 style="">Create New Market</h4>
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.7em">
      <div>Title:</div>
      <div><input bind:value={newMarketTitle} /></div>
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.7em">
      <div>Description:</div>
      <div><textarea bind:value={newMarketDesc} /></div>
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.7em">
      <div>Yes deposit:</div>
      <div><input bind:value={yesDeposit} /></div>
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.7em">
      <div>No deposit:</div>
      <div><input bind:value={noDeposit} /></div>
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.7em">
      <div>End date:</div>
      <div><input bind:value={endDate} /></div>
    </div>
    <div style="padding: 1em; text-align:left; font-size: 0.7em">
      <div>Image URL:</div>
      <div><input bind:value={imageUrl} /></div>
    </div>

    <button class="demo-button" on:click={createMarket}>Create Market</button>
  </div>
</div>

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
    background: rgb(220 218 224 / 25%);
  }
</style>
