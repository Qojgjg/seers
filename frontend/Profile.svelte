<script lang="ts">
  import { onMount } from "svelte"
  import DisplayPost from "./DisplayPost.svelte"
  import DisplayButton from "./DisplayButton.svelte"

  export let auth
  export let handle = ""
  export let signIn
  export let principal

  let anonImage =
    "https://static.wikia.nocookie.net/codegeass/images/c/c0/Zero.jpg"
  let anonCover =
    "https://p0.pikist.com/photos/618/850/japan-landscape-spring-plant-blue-sky-cherry-blossoms-flowers-natural-arboretum.jpg"
  let user = null
  let name = ""
  let age = 42
  let city = ""
  let picture = ""
  // "https://conteudo.imguol.com.br/c/entretenimento/04/2022/02/25/batman-1645790799911_v2_1x1.jpg"
  let cover = ""
  // "https://sm.ign.com/ign_pt/news/t/the-batman/the-batmans-rating-has-been-confirmed_bh3x.jpg"
  let twitter = ""
  let discord = ""
  let bio = ""
  // "Social Network for forecasting. Prediction Markets and much more. Our goal is to predict the future 30% more accurately. Powered by  #InternetComputer"
  let website = ""

  let editMode = false
  let response = null
  let errorResponse = ""
  let errorRefresh = ""
  let refreshLabel = "Refresh"
  let isGetting = false
  let posts = []
  let processing = false

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
    console.log(handle)
    let resp = {}
    if (principal === "" && handle === "") {
      isGetting = true
      setTimeout(getUserData, 500)
    } else if (handle !== "") {
      isGetting = true
      resp = await $auth.actor.getUserWithPosts(handle)
    } else if (principal !== "") {
      isGetting = true
      resp = await $auth.actor.getUserFromPrincipal(principal)
    }
    console.log(resp)
    if ("ok" in resp) {
      const data = resp["ok"]
      user = data[0]
      posts = data[1]
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
        user.posts = posts.reverse()
        picture = user.picture
        cover = user.cover
        name = user.name
        handle = user.handle
        bio = user.bio
        console.log(user)
      }
    }
    isGetting = false
  }

  let createUserData = async () => {
    errorResponse = ""
    age = Number(age)

    let initData = {
      id: principal,
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

    if (editMode) {
      response = await $auth.actor.editUser(initData)
    } else {
      response = await $auth.actor.createUser(initData)
    }
    console.log(response)
    if ("err" in response) {
      errorResponse =
        "Error: " +
        splitCamelCaseToString(Object.keys(response["err"]).toString())
    } else {
      user = response["ok"]
      user.posts = []
    }
    console.log(user)
  }

  let refreshUser = async () => {
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
          src={user.cover ? user.cover : anonCover}
          alt="cover"
          style="width: 100%; height: 300px;object-fit: cover;"
        />
      </div>
      <div
        style="min-width: 200px; margin-bottom: 10px; width: 100%; text-align:start; display:flex;margin-top:-50px; justify-content:space-between"
      >
        <div style="text-align:start; width: 100px">
          <img
            src={user.picture ? user.picture : anonImage}
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
            style="background: black;"
            on:click={() => (editMode = true)}>Edit Profile</button
          >
          <div style="text-align:center;color:red">
            {errorRefresh}
          </div>
        </div>
      </div>
      <div
        style="width: 100%; text-align:start;display:flex; flex-direction:row; border-bottom: 1px solid grey"
      >
        <div style="width: 100%; text-align:start; margin: 5px; padding: 5px">
          {user.bio}
        </div>
      </div>

      <!-- <div
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
      </div> -->
      <div style="margin-top: 40px; width: 100%">
        {#each user.posts as post, i}
          <DisplayPost
            {auth}
            {principal}
            {signIn}
            {post}
            doNotShowBorder={i < user.posts.length - 1 ? false : true}
          />
        {/each}
      </div>
    {:else if principal !== "" && !isGetting}
      <div style="display: flex; align-items: center; flex-direction: column">
        <div style="display:flex; flex-direction:column; align-items:center">
          <div style="padding: 10px; margin: 10px">Handle:</div>
          <input
            bind:value={handle}
            type="text"
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; flex-direction:column;align-items:center">
          <div style="padding: 10px; margin: 10px">Name:</div>
          <input
            bind:value={name}
            style="align-items: center; width:100%; height: 30px"
          />
        </div>
        <div style="display:flex; flex-direction:column;align-items:center">
          <div style="padding: 10px; margin: 10px">Picture:</div>
          <input
            bind:value={picture}
            style="align-items: center; width:100%; height: 30px"
          />
          <img
            src={picture}
            alt="avatar"
            style="width: 200px; border-radius: 15px; padding: 5px"
          />
        </div>
        <div style="display:flex; flex-direction:column;align-items:center">
          <div style="padding: 10px; margin: 10px">Cover:</div>
          <input
            bind:value={cover}
            style="align-items: center; width:100%; height: 30px"
          />
          <img
            src={cover}
            alt="cover"
            style="width: 200px; border-radius: 15px; padding: 5px"
          />
        </div>
        <div
          style="display:flex;flex-direction:column; align-items:center; width: 300px"
        >
          <div style="padding: 10px; margin: 10px">Bio:</div>
          <textarea
            rows="5"
            bind:value={bio}
            style="align-items: center; width:100%; height: 100px"
          />
        </div>

        <DisplayButton
          {principal}
          label="Submit"
          {signIn}
          execute={async () => {
            processing = true
            await createUserData()
            processing = false
          }}
          {errorResponse}
          {processing}
        />
      </div>
    {:else if !isGetting}
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
    {:else}
      Loading
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
    max-width: 600px;
    width: 80%;
    /* background-color: black; */
    /* background-color: rgb(25, 27, 31);
    border: 1px solid rgb(90, 58, 81);
    box-shadow: 2px 2px 20px 0.5px rgb(54, 27, 46); */
    border: 1px solid rgb(90, 58, 81);

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
