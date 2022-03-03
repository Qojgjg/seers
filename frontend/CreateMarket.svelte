<script>
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

<div>
  <div style="">
    <h6 style="">Create new market</h6>
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
    <div>$<input bind:value={yesDeposit} /></div>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>No deposit:</div>
    <div>$<input bind:value={noDeposit} /></div>
  </div>
  <div style="padding: 1em; text-align:left; font-size: 0.7em">
    <div>End date:</div>
    <div><input bind:value={endDate} /></div>
  </div>

  <button class="demo-button" on:click={createMarket}>Create Market</button>
</div>

<style global>
</style>
