<script>
  export let auth

  let labels = ["madrid", "berlin", "lisbon"]
  let newLabel
  let marketCreated = false
  let newMarketTitle = "Champions League: Benfica vs Liverpool."
  let newMarketDesc = "Who will win?"
  let endDate = "10/10/2022"
  let imageUrl =
    "https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/UEFA_Champions_League_logo_2.svg/1200px-UEFA_Champions_League_logo_2.svg.png"

  let createMarket = async () => {
    const liquidity = 3000
    let probabilities = []
    let i = 0

    console.log("labels: " + labels)

    for (; i < labels.length; i++) {
      probabilities.push(BigInt(Math.floor(1000 / labels.length)))
    }

    const marketInitData = {
      title: newMarketTitle,
      description: newMarketDesc,
      labels: labels,
      probabilities: probabilities,
      liquidity: liquidity,
      endDate: Date.parse(endDate) * 1_000_000,
      imageUrl: imageUrl,
    }
    await $auth.actor.createMarket(marketInitData)
    marketCreated = true
  }

  let addOption = () => {
    if (newLabel.length > 0) {
      labels.push(newLabel)
      console.log(labels)
      newLabel = ""
    }
  }
</script>

{#if marketCreated}
  <div class="header">
    <h3>Market created!</h3>
  </div>
  <div class="row" />
{:else}
  <div class="header">
    <h3>Create Market</h3>
  </div>

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
      <div style="width: 80%; padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Image URL:</div>
        <div><input bind:value={imageUrl} size="40" maxlength="200" /></div>
      </div>
      <div style="width: 80%; padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">New option:</div>
        <div style="font-size: 1.5em">
          <input bind:value={newLabel} size="40" maxlength="200" />
        </div>
        <button class="demo-button" on:click={addOption}>Add</button>
      </div>
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
