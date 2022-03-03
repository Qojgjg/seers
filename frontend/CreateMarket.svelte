<script>
  import Header from "./Header.svelte"

  export let auth

  let newMarketTitle
  let newMarketDesc
  let yesDeposit
  let noDeposit
  let endDate

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
    }
    await $auth.actor.createMarket(marketInitData)
  }
</script>

<Header />

<div class="CreateBody">
  <div>
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

    <button class="demo-button" on:click={createMarket}>Create Market</button>
  </div>
</div>

<style global>
  .CreateBody {
    display: flex;
    justify-content: center;
  }
</style>
