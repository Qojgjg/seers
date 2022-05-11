<script lang="ts">
  import { onMount } from "svelte"
  import { useNavigate } from "svelte-navigator"
  import SvelteMarkdown from "svelte-markdown"
  import Chart from "chart.js/auto"
  import Trade from "./Trade.svelte"
  import Forecast from "./Forecast.svelte"
  import Comments from "./Comments.svelte"

  export let auth
  export let id
  export let principal
  export let signIn

  const navigate = useNavigate()

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
      const datasets = market.labels.map((label, idx) => {
        return {
          label: label,
          data: market.histPrices.map((point) => point.probabilities[idx]),
          backgroundColor: [backgrounds[idx]],
          borderColor: [borders[idx]],
          borderWidth: 1,
        }
      })

      console.log("Datasets: " + JSON.stringify(datasets))

      myChart = new Chart(ctx, {
        type: "line",
        data: {
          labels: ["January"],
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

      // myChart = new Chart(ctx, {
      //   type: "line",
      //   data: {
      //     labels: ["January", "February", "March", "April", "May", "June"],
      //     datasets: [
      //       {
      //         label: "No",
      //         data: [90, 80, 70, 95, 80, 70],

      //         backgroundColor: [
      //           "rgba(255, 99, 132, 0.2)",
      //           "rgba(54, 162, 235, 0.2)",
      //           "rgba(255, 206, 86, 0.2)",
      //           "rgba(75, 192, 192, 0.2)",
      //           "rgba(153, 102, 255, 0.2)",
      //           "rgba(255, 159, 64, 0.2)",
      //         ],
      //         borderColor: [
      //           "rgba(255, 99, 132, 1)",
      //           "rgba(54, 162, 235, 1)",
      //           "rgba(255, 206, 86, 1)",
      //           "rgba(75, 192, 192, 1)",
      //           "rgba(153, 102, 255, 1)",
      //           "rgba(255, 159, 64, 1)",
      //         ],
      //         borderWidth: 1,
      //       },
      //       {
      //         label: "Yes",
      //         data: [10, 20, 30, 5, 20, 30],
      //         backgroundColor: [
      //           "rgba(255, 99, 132, 0.2)",
      //           "rgba(54, 162, 235, 0.2)",
      //           "rgba(255, 206, 86, 0.2)",
      //           "rgba(75, 192, 192, 0.2)",
      //           "rgba(153, 102, 255, 0.2)",
      //           "rgba(255, 159, 64, 0.2)",
      //         ],
      //         borderColor: [
      //           "rgba(255, 99, 132, 1)",
      //           "rgba(54, 162, 235, 1)",
      //           "rgba(255, 206, 86, 1)",
      //           "rgba(75, 192, 192, 1)",
      //           "rgba(153, 102, 255, 1)",
      //           "rgba(255, 159, 64, 1)",
      //         ],
      //         borderWidth: 1,
      //       },
      //     ],
      //   },
      //   options: {
      //     scales: {
      //       y: {
      //         beginAtZero: true,
      //       },
      //     },
      //   },
      // })
    }
  }

  const readMarket = async () => {
    market = await $auth.actor.readMarket(parseInt(id))
    if (market) {
      market = market[0]
      if (market) {
        selectedLabel = market.labels[0]
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

<!-- <div class="market-controls">
      <ul
        style="list-style-type: none; margin: 0; padding: 10px; width: 100%; line-height: 1.5em"
      >
        <h4 style="text-align:center; padding: 3px; margin: 3px">Details</h4>
  
        <li>
          <div style="margin:0;padding:0;text-transform:capitalize">
            Status: {Object.keys(market.state).toString()}
          </div>
        </li>
        <li>
          Starts: {new Date(
            parseInt(market.startDate) / 1_000_000,
          ).toDateString()}
        </li>
        <li>
          Ends: {new Date(parseInt(market.endDate) / 1_000_000).toDateString()}
        </li>
        <li>Volume: {Number(market.volume).toFixed(2)} &Sigma;</li>
        <li>
          Liquidity: {Number(market.liquidity).toFixed(2)} &Sigma;
        </li>
      </ul>
    </div> -->

<div
  style="display: flex; padding: 30px; align-items: center; justify-content: center; flex-direction:column; text-align: center"
>
  <div
    style="background: rgba(0, 0, 0, 0.3); width: 80%; max-width: 1000px;padding: 80px; border-style: none; border-width: 2px; border-radius: 10px"
  >
    <div
      style="display:flex; flex-direction: row; justify-content:start; text-align:center"
    >
      <img
        style="width: 100px; height: 100px;border-radius: 50%; margin-right: 15px"
        src={market?.imageUrl}
        alt="market"
      />
      <div style="">
        <h3>{market?.title}</h3>
      </div>
    </div>

    <div style="width: 600px">
      <canvas id="myChart" />
    </div>

    <div style="line-height: 2; text-align:left; font-size: 1.1em">
      <h3>About</h3>
      <SvelteMarkdown source={market?.description} />
    </div>
    <div style="width: 100%; display:flex">
      <div>
        <Trade {auth} {readMarket} {market} />
      </div>
      <div>
        <Forecast />
      </div>
    </div>
    <div style="width: 100%; display:flex">
      <Comments {auth} {marketId} {readMarket} {comments} />
    </div>
  </div>
</div>
{#if market}
  <!-- 
  <div class="rowView">
    <div class="market-comments">
      <div class="market">
        {#if market.imageUrl}{/if}
      </div>
      <div class="market">
        {#each market.comments as comment}
          <div style="margin: 5px 0px">
            <div style="color:pink; padding: 5px 0px">{comment.author}</div>
            <SvelteMarkdown source={comment.content} />
          </div>
        {/each}
        <div class="comment-container">
          <textarea
            bind:value={comment}
            rows="10"
            style="height: auto; width: 100%"
            placeholder="Please share your insight"
          />
          <button class="btn-grad" on:click={postComment}>
            {commentLabel}
          </button>
          <div style="width: 100%;text-align:center;color:red">
            {commentErrorResponse}
          </div>
        </div>
      </div>
    </div>
    <div class="v-container">
      <div class="market-controls">
        <ul
          style="list-style-type: none; margin: 0; padding: 10px; width: 100%; line-height: 1.5em"
        >
          <h4 style="text-align:center; padding: 3px; margin: 3px">Details</h4>

          <li>
            <div style="margin:0;padding:0;text-transform:capitalize">
              Status: {Object.keys(market.state).toString()}
            </div>
          </li>
          <li>
            Starts: {new Date(
              parseInt(market.startDate) / 1_000_000,
            ).toDateString()}
          </li>
          <li>
            Ends: {new Date(
              parseInt(market.endDate) / 1_000_000,
            ).toDateString()}
          </li>
          <li>Volume: {Number(market.volume).toFixed(2)} &Sigma;</li>
          <li>
            Liquidity: {Number(market.liquidity).toFixed(2)} &Sigma;
          </li>
        </ul>
      </div> -->
  <!-- <div class="market-controls">
        <div
          style="display:flex; justify-content:start; text-align:center; align-items:center;flex-direction:column;width: 100%; padding: 10px;"
        >
          <h4>Trade</h4>
          <div class="YesNoOptions">
            <button
              class={buyOptClass}
              on:click={() => {
                buyOptClass = "BuyOptSelected"
                sellOptClass = "SellOpt"
                buyTokens = true
                buttonLabel = "Buy " + selectedLabel
              }}>Buy</button
            >
            <button
              class={sellOptClass}
              on:click={() => {
                buyOptClass = "BuyOpt"
                sellOptClass = "SellOptSelected"
                buyTokens = false
                buttonLabel = "Sell " + selectedLabel
              }}>Sell</button
            >
          </div>
          <div class="OutcomeTitle">Pick Outcome:</div>
          <div class="ContentTab">
            <select
              bind:value={selected}
              style="width: 100%"
              on:change={() => {
                selectedLabel = market.labels[selected]
                if (buyTokens) buttonLabel = "Buy " + selectedLabel
                else buttonLabel = "Sell " + selectedLabel
              }}
            >
              {#each market.labels as label, i}
                <option value={i}>
                  {(Number(market.probabilities[i]) / 1000.0).toFixed(2)} &Sigma;
                  - {label.slice(0, 20)}
                </option>
              {/each}
            </select>
            <div class="OutcomeTitle">Amount:</div>
            <div class="OutcomeTitle">
              <input
                bind:value={seerAmount}
                on:keyup={() => debounce(market.id, seerAmount, 500)}
                style="width:100%; height: 30px"
              />
            </div>
            <div class="ControlData">
              <div>LP fee 0.00%</div>
              <div>
                {#if buyTokens}
                  Avg. price {tokensEstimate
                    ? (seerAmount / tokensEstimate).toFixed(2)
                    : 0} &Sigma;
                {:else}
                  Avg. price {tokensEstimate
                    ? (seerAmount / tokensEstimate).toFixed(2)
                    : 0} tokens
                {/if}
              </div>
              <div>
                {#if buyTokens}
                  Max. Winnings {tokensEstimate
                    ? Number(tokensEstimate).toFixed(2)
                    : Number(0).toFixed(2)}
                  &Sigma;
                {:else}
                  Get back {tokensEstimate
                    ? Number(tokensEstimate).toFixed(2)
                    : Number(0).toFixed(2)} &Sigma;
                {/if}
              </div>
            </div>
            <div
              style="width: 100%; text-align: center; display: flex; flex-direction: column; justify-content: center"
            >
              {#if principal !== ""}
                <Modal show={$modal}>
                  <Content
                    onOk={() => {
                      let res = doIt(market.id, seerAmount)
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
                  <button class="btn-grad" on:click={() => signIn()}>
                    Login
                  </button>
                </div>
              {/if}
            </div>
          </div>
        </div>
      </div> 
    </div>
  </div>-->
{:else}
  <div class="header">Loading</div>
{/if}

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
    background-color: rgb(25, 27, 31);
    color: rgb(255, 255, 255);
    height: 30px;
    margin-top: 10px;
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

    .market-controls {
      margin: 1em;
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
