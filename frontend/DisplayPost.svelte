<script lang="ts">
  import Fa from "svelte-fa"

  import { faComment, faHeart } from "@fortawesome/free-regular-svg-icons"
  import {
    faRetweet,
    faHeart as faSolidHeart,
  } from "@fortawesome/free-solid-svg-icons"
  import inf from "./assets/inf.gif"

  export let auth
  export let principal
  export let signIn
  export let post
  export let isThread = false
  export let doNotShowBorder = false
  export let isMain = false

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
    selected = selected === undefined ? 0 : selected
    const resp = await $auth.actor.buyOutcome(marketId, 100, selected, true)
    processing = false
    console.log(resp)
  }

  const submitLike = async (postId) => {
    const resp = await $auth.actor.submitLike(Number(postId))
    console.log(resp)
    // getPost()
  }
</script>

{#if isMain}
  <div
    id="main"
    style="padding: 0px 0px 0px 0px; width: 100%; border-top: 0px solid grey; "
  >
    <div
      style="display:flex; justify-content:start; text-align:start; width: 100%; padding: 5px 0px; flex-direction:row; align-items:center; font-size: 1.2em; "
    >
      <div style="padding: 0px 0px; margin: 0px 5px; height: 100%;">
        <a href={`/profile/${post?.author.principal}`}>
          <img
            src={post?.author.picture}
            alt="avatar"
            style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%"
          />
        </a>
      </div>
      <div style="display:flex; flex-direction:column; height: 100%">
        <a href={`/profile/${post?.author.principal}`}>{post?.author.name}</a>
        <a href={`/profile/${post?.author.principal}`} style="color:grey">
          @{post?.author.handle}
        </a>
      </div>
    </div>
    <div style="flex-grow: 1; justify-content: start; text-align:start">
      <a href={`/profile/post/${post?.id}#main`} style="width: 100%">
        <div
          style="width: 100%; text-align:start; padding: 0px 0px; border-bottom: 0px solid grey;"
        >
          <div style="padding: 10px 0px; font-size: 1.2em">
            {post?.content}
          </div>
        </div>
      </a>
      {#if post && "market" in post?.postType}
        <div>
          {#each post.market[0].labels as label, i}
            <div
              style="width: 100%; display:flex; cursor:pointer; margin: 0; padding: 0;"
            >
              <div
                style={`background: #39CCCC; width: 60px; padding: 5px 0px 0px 0px; margin: 2px 0px; border: 0px solid black; border-radius: 5px 0px 0px 5px; color:black; text-align:right`}
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
      {:else if post && "image" in post?.postType}
        <div>
          <img
            src={post.image[0]}
            alt="main"
            style="width: 95%; border-radius: 15px; object-fit:cover"
          />
        </div>
      {/if}
      <div style="color:grey; padding: 5px 0px;border-bottom: 1px solid grey;">
        {new Date(parseInt(post?.createdAt) / 1_000_000).toDateString()}
        -
        {new Date(parseInt(post?.createdAt) / 1_000_000).toLocaleTimeString()}
      </div>
      <div
        style="width: 100%; display:flex; gap: 30px; padding: 10px 0px; color:grey; border-bottom: 1px solid grey;"
      >
        <div style="width: 100px; display:flex; gap: 15px">
          <div style="color:white">{post?.retweets.length}</div>
          <div>Retweets</div>
        </div>
        <div style="width: 100px; display:flex; gap: 15px">
          <div style="color:white">{post?.likes.length}</div>
          <div>Likes</div>
        </div>
      </div>
      <div
        style="width: 100%; display:flex; gap: 30px; padding: 10px 0px; color:grey; border-bottom: 1px solid grey;"
      >
        <div style="width: 50px; display:flex; gap: 15px">
          <div><Fa icon={faComment} /></div>
        </div>
        <div style="width: 50px; display:flex; gap: 15px">
          <div><Fa icon={faRetweet} /></div>
        </div>
        <div style="width: 50px; display:flex; gap: 15px">
          <div>
            <button
              on:click={() => {
                if (principal === "") signIn()
                else {
                  const like = {
                    author: {
                      principal,
                      handle: "dummy",
                      name: "dummy",
                      picture: "dummy",
                    },
                    createdAt: Date.now(),
                  }
                  const liked = post.likes.find(
                    (like) => like.author.principal == principal,
                  )

                  console.log(liked)

                  console.log(post.likes.length)
                  if (liked) {
                    post.likes = post.likes.filter(
                      (like) => like.author.principal != principal,
                    )
                  } else {
                    post.likes.push(like)
                    post.likes = post.likes
                  }

                  console.log(post.likes.length)
                  submitLike(post.id)
                }
              }}
              style={`color:${
                post?.likes.find((like) => like.author.principal == principal)
                  ? "#e81c4f"
                  : "grey"
              }`}
              class="like-bt"
            >
              <Fa
                icon={post?.likes.find(
                  (like) => like.author.principal == principal,
                )
                  ? faSolidHeart
                  : faHeart}
              />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
{:else}
  <div
    style={`display:flex; justify-content:start; text-align:start; width: 100%; padding: 0px 0px; flex-direction:row; align-items:center; border-bottom: ${
      isThread || doNotShowBorder ? 0 : 1
    }px solid grey`}
  >
    <div
      style="display:flex; flex-direction:column; padding: 0px; margin: 5px; height: 100%"
    >
      <a href={`/profile/${post.author.principal}`}>
        <img
          src={post.author.picture}
          alt="avatar"
          style="width: 50px; height: 50px; object-fit: cover; border-radius: 50%; padding: 15px 0px 0px 0px;"
        />
      </a>
      {#if isThread}
        <div style="display:flex; justify-content:center; flex-grow: 1">
          <div style="width: 2px; height: 100%; background:rgb(51, 54, 57)">
            &nbsp;
          </div>
        </div>
      {/if}
    </div>
    <div
      style="flex-grow: 1; justify-content: start; text-align:start; padding: 15px 0px;"
    >
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
      <a href={`/profile/post/${post.id}#main`} style="width: 100%">
        <div style="width: 100%; text-align:start; padding: 15px 0px">
          {post.content}
        </div>
      </a>
      {#if "market" in post.postType}
        <div>
          {#each post.market[0].labels as label, i}
            <div
              style="width: 100%; display:flex; cursor:pointer; margin: 0; padding: 0;"
            >
              <div
                style={`background: #39CCCC; width: 60px; padding: 5px 0px 0px 0px; margin: 2px 0px; border: 0px solid black; border-radius: 5px 0px 0px 5px; color:black; text-align:right`}
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
            style="width: 95%; border-radius: 15px; object-fit:cover"
          />
        </div>
      {/if}
      <div
        style="width: 100%; display:flex; gap: 30px; padding: 5px 0px; color:grey"
      >
        <a
          href={`/profile/post/${post.id}#main`}
          style="width: 50px; color:grey"
        >
          <div style="width: 100%; display:flex; gap: 15px;">
            <div><button class="reply-bt"><Fa icon={faComment} /></button></div>
            {#if post.replies.length > 0}<div>{post.replies.length}</div>{/if}
          </div>
        </a>

        <div style="width: 50px; display:flex; gap: 15px">
          <div><button class="retweet-bt"><Fa icon={faRetweet} /></button></div>
          {#if post.retweets.length > 0}<div>{post.retweets.length}</div>{/if}
        </div>
        <div style="width: 50px; display:flex; gap: 15px">
          <div>
            <button
              on:click={() => {
                if (principal === "") {
                  signIn()
                } else {
                  const like = {
                    author: {
                      principal,
                      handle: "dummy",
                      name: "dummy",
                      picture: "dummy",
                    },
                    createdAt: Date.now(),
                  }
                  const liked = post.likes.find(
                    (like) => like.author.principal == principal,
                  )

                  console.log(liked)

                  console.log(post.likes.length)
                  if (liked) {
                    post.likes = post.likes.filter(
                      (like) => like.author.principal != principal,
                    )
                  } else {
                    post.likes.push(like)
                    post.likes = post.likes
                  }

                  console.log(post.likes.length)
                  submitLike(post.id)
                }
              }}
              style={`color:${
                post?.likes.find((like) => like.author.principal == principal)
                  ? "#e81c4f"
                  : "grey"
              }`}
              class="like-bt"
              ><Fa
                icon={post?.likes.find(
                  (like) => like.author.principal == principal,
                )
                  ? faSolidHeart
                  : faHeart}
              /></button
            >
          </div>
          {#if post.likes.length > 0}
            <div
              style={`color:${
                post?.likes.find((like) => like.author.principal == principal)
                  ? "#e81c4f"
                  : "grey"
              }`}
            >
              {post.likes.length}
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
{/if}

<style>
  .like-bt {
    all: unset;
    cursor: pointer;
  }
  .like-bt:hover {
    color: #e81c4f;
  }

  .retweet-bt {
    all: unset;
    cursor: pointer;
  }
  .retweet-bt:hover {
    color: #19cf86;
  }

  .reply-bt {
    all: unset;
    cursor: pointer;
  }
  .reply-bt:hover {
    color: #1da1f2;
  }
</style>
