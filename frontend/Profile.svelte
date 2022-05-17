<script lang="ts">
  import { onMount } from "svelte"
  import { init } from "svelte/internal"

  export let auth
  export let principal
  export let signIn

  let user = null
  let createLabel = "Create User"

  let id = principal
  let handle = "seers"
  let name = "Seers"
  let age = 35
  let city = "Lisbon"
  let picture =
    "https://conteudo.imguol.com.br/c/entretenimento/04/2022/02/25/batman-1645790799911_v2_1x1.jpg"
  let cover =
    "https://sm.ign.com/ign_pt/news/t/the-batman/the-batmans-rating-has-been-confirmed_bh3x.jpg"
  let twitter = "@SeerMarkets"
  let discord = "none"
  let bio =
    "Social Network for forecasting. Prediction Markets and much more. Our goal is to predict the future 30% more accurately. Powered by  #InternetComputer"
  let website = "seers.bet"

  let editMode = false
  let response = null
  let errorResponse = ""
  let errorRefresh = ""
  let refreshLabel = "Refresh"
  let isGetting = false

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const getMarketLabel = (id, idx) => {
    let market = user.markets.find((m) => m.marketId == id)
    if (market) {
      return market.labels[idx]
    } else {
      return "Null"
    }
  }

  let getUserData = async () => {
    if (principal === "") {
      setTimeout(getUserData, 500)
    } else {
      isGetting = true
      user = await $auth.actor.getUserStable(principal)
      isGetting = false
      if (user) {
        user = user[0]
        if (user) {
          user.markets = user.markets.sort(function (a, b) {
            var keyA = Number(a.marketId),
              keyB = Number(b.marketId)
            if (keyA < keyB) return -1
            if (keyA > keyB) return 1
            return 0
          })
          user.ownMarkets = user.markets.filter((m) => m.author)
          user.otherMarkets = user.markets.filter((m) => !m.author)
          user.txs = user.txs.reverse()
          console.log(user)
        }
      }
    }
  }

  let createUserData = async () => {
    createLabel = "Processing..."
    errorResponse = ""
    age = Number(age)

    let initData = {
      id,
      handle,
      name,
      age,
      city,
      picture,
      cover,
      twitter,
      discord,
      bio,
      website,
    }

    response = await $auth.actor.createUser(initData)
    if (response["err"]) {
      errorResponse =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      user = response["ok"]
    }
    createLabel = "Create User"
    console.log(user)
  }

  let refreshUser = async () => {
    refreshLabel = "Processing..."
    response = await $auth.actor.refreshUser()
    if (response["err"]) {
      errorRefresh =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      errorRefresh = ""
      user = response["ok"]
      if (user) {
        user.markets = user.markets.sort(function (a, b) {
          var keyA = Number(a.marketId),
            keyB = Number(b.marketId)
          if (keyA < keyB) return -1
          if (keyA > keyB) return 1
          return 0
        })
        user.ownMarkets = user.markets.filter((m) => m.author)
        user.otherMarkets = user.markets.filter((m) => !m.author)
        user.txs = user.txs.reverse()
        console.log(user)
      }
    }
    refreshLabel = "Refresh"
  }
  onMount(getUserData)
</script>

{#if !user}
  <div class="header">
    <h3>Create Profile</h3>
  </div>
{/if}

<div style="justify-content: center; display: flex;width: 100%">
  <div class="rowUser">
    {#if user && !editMode}
      <div style="margin-bottom: 10px; width: 100%; text-align:center">
        <img
          src={user.cover}
          alt="cover"
          style="width: 100%; height: 300px;object-fit: cover;"
        />
      </div>
      <div
        style="min-width: 200px; margin-bottom: 10px; width: 100%; text-align:start; display:flex;margin-top:-50px; justify-content:space-between"
      >
        <div style="text-align:start; width: 100px">
          <img
            src={user.picture}
            alt="avatar"
            style="width: 100px; height: 100px; border-radius:50%; object-fit:cover;"
          />
        </div>
        <div
          style="margin-left: 5px; margin-top: 40px; flex-grow:1; justify-content:start"
        >
          <div>{user.name}</div>
          <div style="color:gray">@{user.handle}</div>
        </div>
        <div
          style="margin-bottom: 10px; width: 100px; text-align:end; display: flex; justify-content:end"
        >
          <button
            class="btn-grad"
            style="background:black"
            on:click={() => (editMode = true)}>Edit Profile</button
          >
          <div style="text-align:center;color:red">
            {errorRefresh}
          </div>
        </div>
      </div>
      <div
        style="width: 100%; text-align:start;display:flex; flex-direction:row"
      >
        <div style="width: 100%; text-align:start; margin: 5px; padding: 5px">
          {user.bio}
        </div>
      </div>

      <div
        style="width: 100%; text-align: center; color: grey; justify-content:space-between; display:flex;margin:5px;padding:5px"
      >
        <div>City: {user.city}</div>
        <div>Twitter: {user.twitter}</div>
        <div>Discord: {user.discord}</div>
        <div>
          Website: <a href={`http://${user.website}`} alt="web"
            >{user.website}</a
          >
        </div>
      </div>

      {#if user.ownMarkets?.length > 0}
        <div style="display:flex; flex-direction: column;width: 100%">
          My markets
          {#each user.ownMarkets as market}
            <a href="/market/{market.marketId}">
              <div
                style="border-radius: 5px; display:flex; align-items: center; align-content: center; flex-direction: column; gap: 10px; margin-top: 10px; padding: 10px; background-color: rgb(220 218 224 / 10%); "
              >
                <div style="width: 100%; display: flex">
                  <div style="width:fit-content; margin-right: 10px">
                    #{market.marketId}:
                  </div>
                  <div style="width: auto">
                    {market.title}
                  </div>
                </div>
                <div style="width: 100%">
                  {#each market.labels as label, i}
                    {#if market.balances[i] > 0.0}
                      {label +
                        ": " +
                        Number(market.balances[i]).toFixed(2) +
                        "  "}
                    {/if}
                  {/each}
                </div>
              </div>
            </a>
          {/each}
        </div>
        <div style="display:flex; flex-direction: column;width: 100%">
          {#if user.otherMarkets?.length > 0}
            Portfolio
            {#each user.otherMarkets as market}
              <a href="/market/{market.marketId}">
                <div
                  style="border-radius: 5px; display:flex; align-items: center; align-content: center; flex-direction: column; gap: 10px; margin-top: 10px; padding: 10px; background-color: rgb(220 218 224 / 10%); "
                >
                  <div style="width: 100%; display: flex">
                    <div style="width:fit-content; margin-right: 10px">
                      #{market.marketId}:
                    </div>
                    <div style="width: auto">
                      {market.title}
                    </div>
                  </div>
                  <div style="width: 100%">
                    {#each market.labels as label, i}
                      {#if market.balances[i] > 0.0}
                        {label +
                          ": " +
                          Number(market.balances[i]).toFixed(2) +
                          "  "}
                      {/if}
                    {/each}
                  </div>
                </div>
              </a>
            {/each}
          {/if}
        </div>
      {/if}
      {#if user.txs.length}
        <div
          style="display:flex; flex-direction: column;width: 100%; margin-top: 20px"
        >
          Transactions
          {#each user.txs as tx, i}
            <div
              style="border-radius: 5px; display:flex; align-items: center; align-content: center; flex-direction: column; gap: 10px; margin-top: 10px; padding: 10px; background-color: rgb(220 218 224 / 10%); "
            >
              <div style="width: 100%; display: flex; flex-wrap: wrap">
                <div style="width:fit-content; margin-right: 10px">
                  #{user.txs.length - i}:
                </div>
                <div style="width: auto; margin-right: 10px;">
                  Market {tx.marketId}
                </div>
                <div
                  style="width: auto;margin-right: 10px; text-transform:capitalize"
                >
                  From {tx.src.length > 0
                    ? getMarketLabel(tx.marketId, tx.src).slice(0, 30)
                    : "seers"}
                </div>
                <div
                  style="width: auto;margin-right: 10px;text-transform:capitalize"
                >
                  To {tx.dest.length > 0
                    ? getMarketLabel(tx.marketId, tx.dest).slice(0, 30)
                    : "seers"}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Price {(tx.sent / tx.recv).toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Received {tx.recv.toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Spent {tx.sent.toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Fee {tx.fee.toFixed(2)}
                </div>
                <div style="width: auto;margin-right: 10px;">
                  Date {new Date(
                    parseInt(tx.createdAt) / 1_000_000,
                  ).toLocaleDateString()}
                </div>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    {:else if isGetting}
      Loading
    {:else if principal !== ""}
      <div style="display: flex; align-items: center; flex-direction: column">
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Handle:</div>
          <input
            bind:value={handle}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Display Name:</div>
          <input
            bind:value={name}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Age:</div>
          <input
            bind:value={age}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">City:</div>
          <input
            bind:value={city}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Picture:</div>
          <input
            bind:value={picture}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Cover:</div>
          <input
            bind:value={cover}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Twitter:</div>
          <input
            bind:value={twitter}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Discord:</div>
          <input
            bind:value={discord}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Website:</div>
          <input
            bind:value={website}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; align-items:center">
          <div style="padding: 10px; margin: 10px">Bio:</div>
          <input
            bind:value={bio}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="width: 100%;display:flex; justify-content:center">
          <button
            class="btn-grad"
            on:input={() => (errorResponse = "")}
            on:click={() => {
              createUserData()
            }}>{createLabel}</button
          >
        </div>
        <br />
        <div style="text-align:center;color:red">
          {errorResponse}
        </div>
      </div>
    {:else}
      <div style="display: flex; align-items: center; flex-direction: column">
        <div style="width: 100%;display:flex; justify-content:center">
          <button
            class="btn-grad"
            on:click={() => {
              signIn()
            }}>Login</button
          >
        </div>
      </div>
    {/if}
  </div>
</div>

<style global>
  .rowUser {
    display: flex;
    flex-wrap: wrap;
    padding: 1em;
    justify-content: start;
    min-width: 200px;
    max-width: 800px;
    width: 80%;
    background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46);

    /* border: 2px solid rgb(25, 27, 31); */
    border-radius: 16px;
    justify-content: center;
    color: rgb(255, 255, 255);
  }

  .btn-grad {
    background-image: linear-gradient(
      to right,
      #4776e6 0%,
      #8e54e9 51%,
      #4776e6 100%
    );
  }
  .btn-grad {
    height: 40px;
    margin: 1em;
    padding: 0em 1em;
    text-align: center;
    text-transform: capitalize;
    transition: 0.5s;
    background-size: 200% auto;
    color: white;
    box-shadow: 0 0 1px #eee;
    border-radius: 10px;
    display: block;
    outline: 0;
    border: 0;
    cursor: pointer;
    min-width: 100px;
    max-width: 150px;
    white-space: normal;
  }

  .btn-grad:hover {
    background-position: right center; /* change the direction of the change here */
    color: #fff;
    text-decoration: none;
  }

  /* .btn-grad {
      background-image: linear-gradient(
        to right,
        #00c6ff 0%,
        #0072ff 51%,
        #00c6ff 100%
      );
    }
    .btn-grad {
      height: 40px;
      margin: 1em;
      padding: 0 1em;
      text-align: center;
      text-transform: capitalize;
      transition: 0.5s;
      background-size: 200% auto;
      color: white;
      box-shadow: 0 0 2px #eee;
      border-radius: 10px;
      display: block;
      outline: 0;
      border: 0;
      cursor: pointer;
      min-width: 100px;
      max-width: 150px;
      white-space: normal;
    }
  
    .btn-grad:hover {
      background-position: right center; 
      color: #fff;
      text-decoration: none;
    } 
    */
  /* 
    .demo-button {
      height: 40px;
      background: rgb(33, 114, 229);
      box-shadow: rgb(0 0 0 / 8%) 0px 6px 10px;
      padding: 0 1em;
      margin: 1em;
      border-radius: 10px;
      font-size: 0.9em;
      outline: 0;
      border: 0;
      cursor: pointer;
      color: white;
      max-width: 150px;
      white-space: normal;
    }
  
    .demo-button:hover {
      background: rgb(25, 108, 224);
    } */
</style>
