<script lang="ts">
  import { onMount } from "svelte"
  import SvelteMarkdown from "svelte-markdown"
  import Chart from "chart.js/auto"
  import Trade from "./Trade.svelte"
  import Forecast from "./Forecast.svelte"
  import Comments from "./Comments.svelte"

  export let auth
  export let id
  export let principal
  export let signIn

  let market
  let marketId
  let selectedLabel
  let comments
  let myChart

  const createChart = () => {
    if (myChart) myChart.destroy()
    const ctx = document.getElementById("myChart") as HTMLCanvasElement
    const backgrounds = [
      "rgba(54, 162, 235, 0.2)",
      "rgba(255, 99, 132, 0.2)",
      "rgba(255, 206, 86, 0.2)",
      "rgba(75, 192, 192, 0.2)",
      "rgba(153, 102, 255, 0.2)",
      "rgba(255, 159, 64, 0.2)",
    ]
    const borders = [
      "rgba(54, 162, 235, 1)",
      "rgba(255, 99, 132, 1)",
      "rgba(255, 206, 86, 1)",
      "rgba(75, 192, 192, 1)",
      "rgba(153, 102, 255, 1)",
      "rgba(255, 159, 64, 1)",
    ]

    if (market) {
      if (market.histPrices.length == 1) {
        market.histPrices.push(market.histPrices[0])
      }
      const datasets = market.labels.map((label, idx) => {
        return {
          label: label.label,
          data: market.histPrices.map((point) => point.probabilities[idx]),
          backgroundColor: [backgrounds[idx]],
          borderColor: [borders[idx]],
          borderWidth: 1,
        }
      })

      console.log("Datasets: " + JSON.stringify(datasets))

      const dates = market.histPrices.map((point) =>
        new Date(Number(point.createdAt) / 1_000_000).toLocaleDateString(),
      )

      myChart = new Chart(ctx, {
        type: "line",
        data: {
          labels: dates,
          datasets: datasets,
        },
        options: {
          scales: {
            y: {
              beginAtZero: true,
            },
          },
        },
      })
    }
  }

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(id))
    if (market) {
      market = market[0]
      if (market) {
        selectedLabel = market.labels[0]
        market.labels = market.labels.map((label) => {
          return { label, value: 0.0 }
        })
        comments = market.comments
        marketId = market.id
        const authors = market.comments.map((c) => c.author)
        const usersData = await $auth.actor.readUserData(authors)
        console.log(usersData)
        let completeComments = []
        for (let comment of comments) {
          for (const data of usersData) {
            if (comment.author == data.principal) {
              comment.handle = data.handle
              comment.picture =
                "https://assets.reedpopcdn.com/the-batman-hbo-max.jpg"
              completeComments.push(comment)
              break
            }
          }
        }
        comments = completeComments
        createChart()
      }
    }
  }

  onMount(readMarket)
</script>

<div
  style="display: flex; padding: 30px; align-items: center; justify-content: center; flex-direction:column; text-align: center"
>
  <div class="rowUser">
    <div
      style="display:flex; flex-direction: row; justify-content:start; text-align:center"
    >
      {#if market?.imageUrl.legnth > 10}
        <img
          style="width: 150px; height: fit-content; border-radius: 5px; margin-right: 15px"
          src={market?.imageUrl}
          alt="market"
        />
      {/if}
      <div style="">
        <h3>{market?.title}</h3>

        <div class="">
          <div
            style="display:flex; margin: 0; padding: 10px; width: 100%; line-height: 1.5em; gap: 10px; color:gray"
          >
            <div>
              <div style="margin:0;padding:0;text-transform:capitalize">
                Status: {market ? Object.keys(market?.state).toString() : ""}
              </div>
            </div>
            <div>
              Starts: {new Date(
                parseInt(market?.startDate) / 1_000_000,
              ).toDateString()}
            </div>
            <div>
              Ends: {new Date(
                parseInt(market?.endDate) / 1_000_000,
              ).toDateString()}
            </div>
            <div>Volume: {Number(market?.volume).toFixed(0)} &Sigma;</div>
            <div>
              Liquidity: {Number(market?.liquidity).toFixed(0)} &Sigma;
            </div>
          </div>
        </div>
      </div>
    </div>
    <div style="display:flex;margin-top: 50px; width: 100%">
      <div style="width: 100%">
        <canvas id="myChart" />

        <div style="line-height: 2; text-align:left; font-size: 1.1em">
          <h3>Market Rules</h3>
          <SvelteMarkdown source={market?.description} />
        </div>
      </div>

      <!-- <div
        style="width: 30%; display:flex; flex-direction:column; padding-left: 20px"
      >
        <div>
          <Trade
            {auth}
            {readMarket}
            {market}
            {principal}
            {selectedLabel}
            {signIn}
          />
        </div>
        <div>
          <Forecast {auth} {readMarket} {market} {principal} {signIn} />
        </div>
      </div> -->
    </div>
  </div>
  <!-- <div
      style="margin: 15px 0px;display:flex;background: rgba(0, 0, 0, 0.3); width: 80%; max-width: 1000px;padding: 40px 80px; border-style: none; border-width: 2px; border-radius: 10px"
    >
      <div style="width: 100%; display:flex">
        <Comments
          {auth}
          {marketId}
          {readMarket}
          {comments}
          {principal}
          {signIn}
        />
      </div>
    </div> -->
</div>

<style global>
  .comment-container {
    margin: 25px 0px 5px 0px;
    width: 100%;
    align-items: center;
  }
  .comment-input {
    width: 100%;
    height: 30px;
    padding: 15px;
    border: hidden;
    border-radius: 20px;
    min-width: 200px;
  }

  select:focus,
  textarea:focus,
  input:focus {
    outline: none;
  }
  select {
    border: 1px solid rgb(90, 58, 81);
    background-color: black;
    color: rgb(255, 255, 255);
    height: 30px;
    font-size: 1.2em;
    text-align: center;
    width: 200px;
    padding: 5px;
  }
  .header {
    display: flex;
    text-align: center;
    justify-content: center;
    padding-top: 60px;
    width: 100%;
    outline: none;
  }

  h3 {
    outline: none;
  }

  .rowView {
    display: flex;
    flex-wrap: wrap;
    /* padding-top: 40px; */
    justify-content: center;
    width: 100%;
  }

  .menu-button {
    color: white;
    background: rgb(220 218 224 / 25%);
    padding: 5px;
    margin: 3px 0px;
    border-radius: 5px;
    font-size: 1em;
    height: 33px;
    border: 0;
    align-items: center;
    text-align: center;
    border-color: white;
    cursor: pointer;
    text-decoration: none;
  }

  .menu-button-selected {
    color: white;
    background: rgba(12, 3, 43, 0.9);
    padding: 5px;
    margin: 3px 0px;
    border-radius: 5px;
    font-size: 1em;
    height: 33px;
    border: 0;
    align-items: center;
    text-align: center;
    border-color: white;
    cursor: pointer;
    text-decoration: none;
  }

  button {
    border: none;
    padding: 3px;
  }

  .Image {
    border-radius: 8px;
    width: 150px;
    float: left;
    padding: 0px 10px 10px 0px;
  }

  .ControlData {
    margin-top: 0.5em;
  }

  .container {
    display: flex;
    justify-content: center;
  }
  .v-container {
    display: flex;
    flex-direction: column;
    justify-content: start;
    margin: 0em 1em;
  }
  .market-comments {
    display: flex;
    flex-direction: column;
    max-width: 40%;
    min-width: 400px;
    margin-bottom: 1em;
    overflow: auto;
    flex-direction: column;
    height: fit-content;
    margin: 0em 1em;
    /* padding: 2em; */
    word-wrap: break-word;
    justify-content: space-between;
  }

  .market {
    padding: 2em;

    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    color: rgb(255, 255, 255);
    justify-content: space-between;
    font-family: "Inter", sans-serif;
    margin: 0em 1em;
    word-wrap: break-word;
    /* overflow: auto; */
    flex-direction: column;
    height: fit-content;
    /* width: max-content; */
    /* min-width: 400px;
    max-width: 100%;*/
    margin-bottom: 1em;
  }

  @media only screen and (max-width: 600px) {
    .market {
      margin: 1em;
      display: flex;
      flex-direction: column;
      justify-content: center;
      /* width: 300px;
      min-width: 0px;
      max-width: 80%; */
    }

    .market-comments {
      width: 330px;
      max-width: 80%;
      min-width: 0px;
    }

    .comment-container {
      flex-direction: column;
      display: flex;
    }
  }

  .market-controls {
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);
    margin: 1em;
    padding: 10px 30px;
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);
    border-radius: 16px;
    justify-content: space-between;
    font-family: "Inter", sans-serif;
    font-size: 1rem;
    font-weight: 500;
    word-break: break-word;
    overflow: hidden;
    white-space: nowrap;
    height: fit-content;
    border-radius: 1em;
    word-wrap: break-word;
    overflow: auto;
    display: flex;
    justify-content: center;
  }
  .MarketDetails {
    display: flex;
    justify-content: center;
    align-items: flex-start;
  }

  .MarketHeader {
    display: flex;
    align-items: flex-start;
    justify-content: flex-start;
    text-align: start;
  }

  .App-logo {
    height: 15vmin;
    pointer-events: none;
  }

  .App-header {
    margin-top: 150px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: calc(10px + 2vmin);
  }

  .App-link {
    color: rgb(26, 117, 255);
  }

  .tton {
    background: black;
    padding: 0 1em;
    margin-top: 1em;
    border-radius: 10px;
    font-size: 0.9em;
    height: 35px;
    outline: 0;
    border: 0;
    cursor: pointer;
    color: white;
    max-width: 200px;
  }
</style>
