<script>
  export let auth

  let labels
  let images
  let marketCreated = false
  let newMarketTitle
  let newMarketDesc
  let endDate
  let imageUrl

  let createMarket = async () => {
    const liquidity = 100
    let probabilities = []
    let i = 0

    labels = labels.split(",").map((s) => s.trim())
    images = images.split(",").map((s) => s.trim())

    for (; i < labels.length; i++) {
      probabilities.push(BigInt(Math.floor(1000 / labels.length)))
    }

    const marketInitData = {
      title: newMarketTitle,
      description: newMarketDesc,
      labels: labels,
      images: images,
      probabilities: probabilities,
      liquidity: liquidity,
      endDate: Date.parse(endDate) * 1_000_000,
      imageUrl: imageUrl,
    }
    await $auth.actor.createMarket(marketInitData)
    marketCreated = true
  }
</script>

{#if marketCreated}
  <div class="header">
    <h3>Market created!</h3>
  </div>
  <div class="rowCreate" />
{:else}
  <div class="header">
    <h3>Create Market</h3>
  </div>

  <div class="rowCreate">
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
        <div style="font-size: 1.5em">Image link:</div>
        <div><input bind:value={imageUrl} size="40" maxlength="200" /></div>
      </div>
      <div style="width: 80%; padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Options: (eg. 'yes,no')</div>
        <div style="font-size: 1.5em">
          <input bind:value={labels} size="40" maxlength="1000" />
        </div>
      </div>
      <div style="width: 80%; padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">Options images: (optional)</div>
        <div style="font-size: 1.5em">
          <input bind:value={images} size="40" maxlength="1000" />
        </div>
      </div>
      <div style="width: 80%;padding: 1em; text-align:left; font-size: 0.7em">
        <div style="font-size: 1.5em">End date:</div>
        <div><input bind:value={endDate} size="20" maxlength="10" /></div>
      </div>
      <div style="width: 100%;text-align:center; ">
        <button class="demo-button" on:click={createMarket}>Create</button>
      </div>
    </div>
  </div>
{/if}

<style global>
  .rowCreate {
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

    background-color: rgb(25, 27, 31);
    border: 2px solid rgb(25, 27, 31);
    border-radius: 16px;
    color: rgb(255, 255, 255);
    /*     
    border-radius: 5px;
    background: rgb(220 218 224 / 10%); */
  }
</style>
