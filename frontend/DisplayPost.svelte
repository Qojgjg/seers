<script lang="ts">
  import Fa from "svelte-fa"
  import { Link } from "svelte-navigator"

  import { faComment, faHeart } from "@fortawesome/free-regular-svg-icons"
  import { faRetweet } from "@fortawesome/free-solid-svg-icons"
  import inf from "./assets/inf.gif"
  import ListMarkets from "./ListMarkets.svelte"

  export let auth
  export let principal
  export let signIn
  export let post

  let errorResponse = ""
  let processing = false

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  function parseTwitterDate(tdate) {
    var system_date = new Date(tdate)
    var user_date = new Date()

    var diff = Math.floor((Number(user_date) - Number(system_date)) / 1000)
    if (diff <= 1) {
      return "now"
    }
    if (diff < 60) {
      return diff + "s"
    }
    if (diff <= 90) {
      return "1m"
    }
    if (diff <= 3540) {
      return Math.round(diff / 60) + "m"
    }
    if (diff <= 5400) {
      return "1h"
    }
    if (diff <= 86400) {
      return Math.round(diff / 3600) + "h"
    }
    if (diff <= 129600) {
      return "1d"
    }
    if (diff < 604800) {
      return Math.round(diff / 86400) + "d"
    }
    if (diff <= 777600) {
      return "1w"
    }
    return "on " + system_date
  }

  const submitBuy = async (marketId, selected) => {
    processing = true
    const resp = await $auth.actor.buyOutcome(marketId, 100, selected, true)
    processing = false
    console.log(resp)
  }
</script>

<div
  style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 15px 0px; flex-direction:row; align-items:center; border-bottom: 1px solid grey"
>
  <div style="padding: 5px; margin: 5px; height: 100%">
    <a href={`/profile/${post.author.principal}`}>
      <img
        src={post.author.picture}
        alt="avatar"
        style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
      />
    </a>
  </div>
  <div style="flex-grow: 1; justify-content: start; text-align:start">
    <div style="display:flex; gap: 5px;">
      <div>
        <a href={`/profile/${post.author.principal}`}>{post.author.name}</a>
      </div>
      <div style="color:grey">
        <a href={`/profile/principal`} style="color:grey">
          @{post.author.handle}
        </a>
      </div>
      <div style="color:grey">
        - {parseTwitterDate(parseInt(post.createdAt) / 1_000_000)}
      </div>
      <!-- <div style="color:grey">- retweeted by @marcio</div> -->
    </div>
    <Link to={`/profile/post/${post.id}#main`} style="width: 100%">
      <div style="width: 100%; text-align:start; padding: 15px 0px">
        {post.content}
      </div>
    </Link>
    {#if "market" in post.postType}
      <div>
        {#each post.market[0].labels as label, i}
          <div
            style="width: 100%; display:flex; cursor:pointer; margin: 0; padding: 0;"
          >
            <div
              style={`background: #39CCCC; width: fit-content; padding: 5px; margin: 2px 0px; border: 0px solid black; border-radius: 5px 0px 0px 5px; color:black`}
            >
              <button
                style="all:unset; width: 100%"
                on:click={() => {
                  post.market[0].selected = i
                }}
              >
                {label}
              </button>
            </div>
            <div style="flex-grow: 1;">
              <div
                style={`background: #39CCCC; width: ${
                  post.market[0].probabilities[i] * 100.0
                }%; padding: 5px 0px; margin: 2px 0px; border: 0px solid black; border-radius: 0px 5px 5px 0px; color:black`}
              >
                <button
                  style="all:unset; width: 100%"
                  on:click={() => {
                    post.market[0].selected = i
                  }}
                />
              </div>
            </div>
            <div
              style="width: 60px; justify-content:flex-end; text-align:end; margin-right: 30px; padding: 5px"
            >
              {post.market[0].probabilities[i].toFixed(2)} &Sigma;
            </div>
          </div>
        {/each}
        <div
          style="display:flex; text-align:end; justify-content:start; flex-grow: 1"
        >
          {#if processing}
            <button
              class="btn-grad"
              style="background: black;width: 100px; margin: 15px 0px; color:white;overflow:hidden;"
              on:click={() => {
                if (principal === "") {
                  signIn()
                } else {
                  submitBuy(post.market[0].id, post.market[0].selected)
                }
              }}
            >
              <img
                src={inf}
                alt="inf"
                style="width: 150px; height: 400%; margin: -100%;"
              />
            </button>
          {:else}
            <button
              class="btn-grad"
              style="background: black; padding: 5px; margin: 15px 0px; color: white"
              on:click={() => {
                if (principal === "") {
                  signIn()
                } else {
                  submitBuy(post.market[0].id, post.market[0].selected)
                }
              }}>Bet</button
            >
          {/if}
          <div style="text-align:end;color:red">
            {errorResponse}
          </div>
        </div>
      </div>
    {:else if "image" in post.postType}
      <div>
        <img
          src={post.image[0]}
          alt="main"
          style="width: 60%; border-radius: 15px; object-fit:cover"
        />
      </div>
    {/if}
    <div
      style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
    >
      <div style="width: 50px; display:flex; gap: 15px">
        <div><Fa icon={faComment} /></div>
        <div>{post.replies.length}</div>
      </div>
      <div style="width: 50px; display:flex; gap: 15px">
        <div><Fa icon={faRetweet} /></div>
        <div>{post.retweets.length}</div>
      </div>
      <div style="width: 50px; display:flex; gap: 15px">
        <div><Fa icon={faHeart} /></div>
        <div>{post.likes.length}</div>
      </div>
    </div>
  </div>
</div>
