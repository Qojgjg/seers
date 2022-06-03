<script lang="ts">
  import { onMount } from "svelte"
  import Fa from "svelte-fa"

  import { faChartBar, faImage } from "@fortawesome/free-regular-svg-icons"
  import { faPlus } from "@fortawesome/free-solid-svg-icons"
  import DisplayPost from "./DisplayPost.svelte"
  import DisplayButton from "./DisplayButton.svelte"

  export let auth
  export let principal
  export let signIn

  let post = ""
  let errorResponse = ""
  let feed = []
  let processing = false
  let showBetForm = false
  let showImageForm = false
  let startDate = ""
  let endDate = ""
  let image = {
    label: "Image URL",
    value:
      "https://media.istockphoto.com/vectors/thumbnail-image-vector-graphic-vector-id1147544808?k=20&m=1147544808&s=612x612&w=0&h=8CUTlOdLd2d5HqO7p6kREJHyxDyAH0VeFA6u7mOQXbo=",
  }
  let outcomes = [
    { id: 1, label: "Outcome 1", value: "" },
    { id: 2, label: "Outcome 2", value: "" },
  ]

  const submitPost = async () => {
    processing = true
    let initData = {
      id: 0,
      author: {
        principal,
        picture: "",
        handle: "",
        name: "",
      },
      content: post,
      parent: [],
      image: [],
      market: [],
      retweet: [],
      isRetweet: [],
    }
    const r = await $auth.actor.submitPost(initData, [])
    console.log(r)
    processing = false
    post = ""
    getFeed()
  }

  const splitCamelCaseToString = (s) => {
    return s
      .split(/(?=[A-Z])/)
      .map((p) => {
        return p[0].toUpperCase() + p.slice(1)
      })
      .join(" ")
  }

  const submitImage = async () => {
    processing = true
    let initData = {
      id: 0,
      author: {
        principal,
        picture: "",
        handle: "",
        name: "",
      },
      content: post,
      parent: [],
      image: [image.value],
      market: [],
      retweet: [],
      isRetweet: [],
    }
    const r = await $auth.actor.submitPost(initData, [])
    showImageForm = false
    console.log(r)
    processing = false
    post = ""
    getFeed()
  }

  const submitMarket = async () => {
    processing = true
    let labels = outcomes.map((o) => o.value)

    let i = 0
    let probabilities = []
    for (; i < labels.length; i++) {
      probabilities.push(1.0 / labels.length)
    }

    const marketInitData = {
      id: 0,
      title: post,
      description: post,
      labels,
      images: [],
      probabilities: probabilities,
      category: { crypto: null },
      liquidity: 1000,
      startDate: Date.parse(startDate) * 1_000_000,
      endDate: Date.parse(endDate) * 1_000_000,
      imageUrl: "nothing",
      collateralType: { seers: null },
      author: "",
    }
    let initData = {
      id: 0,
      author: {
        principal,
        picture: "",
        handle: "",
        name: "",
      },
      content: post,
      parent: [],
      image: [image.value],
      market: [],
      retweet: [],
      isRetweet: [],
    }
    const resp = await $auth.actor.submitPost(initData, [marketInitData])
    processing = false
    showBetForm = false
    if (resp["err"]) {
      errorResponse =
        "Error: " + splitCamelCaseToString(Object.keys(resp["err"]).toString())
    } else {
      console.log(resp)
      getFeed()
    }
  }

  const getFeed = async () => {
    feed = await $auth.actor.getFeed()
    feed = feed.reverse()
    console.log(feed)
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

  onMount(getFeed)
</script>

<div
  style="justify-content: center; display: flex;width: 100%; margin-top: 20px; flex-direction:column; align-items:center; gap: 20px"
>
  <div class="rowUser">
    <div style="width: 100%; margin: 0px; padding: 5px">
      <textarea
        bind:value={post}
        rows="3"
        style="width: 100%; font-size: 1.3em; background: black;color:white;border: 0px solid rgb(90, 58, 81); padding: 5px; border-radius: 15px"
        placeholder={showBetForm ? "Ask a question..." : "What's happening?"}
      />
      {#if showBetForm}
        <div
          style="display:flex; flex-direction: column; width: 100%; height: fit-content; border: 1px solid rgb(47, 51, 54); border-radius: 16px; align-items:flex-end"
        >
          <div
            style="display:flex; width: 100%; height: fit-content; border: 0px solid rgb(47, 51, 54); align-items:flex-end"
          >
            <div
              style="display: flex; flex-direction:column; flex-grow: 1; justify-content:space-evenly"
            >
              {#each outcomes as outcome (outcome.id)}
                <div
                  style="height: 50px; border: 1px solid rgb(51, 54, 57); border-radius:4px; padding: 5px; margin: 15px"
                >
                  <input
                    bind:value={outcome.value}
                    type="text"
                    placeholder={outcome.label}
                    style="background: black; border: 0px; width: 100%; height: 100%; color:white; font-size: 1.2em;"
                  />
                </div>
              {/each}
            </div>

            <div
              style="width: 50px; height: 60px  ; display:flex; justify-content:center; align-items:flex-end; "
            >
              <div
                style="height: 100%"
                on:click={() => {
                  outcomes.push({
                    id: outcomes.length + 1,
                    label: `Outcome ${outcomes.length + 1}`,
                    value: "",
                  })
                  outcomes = outcomes
                  console.log(outcomes)
                }}
              >
                <Fa icon={faPlus} scale={1.3} />
              </div>
            </div>
          </div>
          <div
            style="display:flex; width: 100%; height: 70px; border-top: 1px solid rgb(47, 51, 54); align-items:flex-end;"
          >
            <div
              style="display:flex; width: 100%; height: 100%; padding: 0px 5px;"
            >
              <div
                style="width: 50%; height: 100%; border-right: 1px solid rgb(47, 51, 54); display:flex; flex-direction:column; justify-content:center; padding: 0px 10px"
              >
                <label for="start" style="width: 100%; color:grey"
                  >Start date:</label
                >

                <input
                  type="date"
                  id="start"
                  bind:value={startDate}
                  min="2022-01-01"
                  max="2050-01-01"
                  style="background: black; color:grey; border: 0px; font-size: 1.5em"
                />
              </div>
              <div
                style="width: 50%; height: 100%; border-right: 0px solid rgb(47, 51, 54); display:flex; flex-direction:column; justify-content:center; padding: 0px 10px"
              >
                <label for="start" style="width: 100%; color:grey"
                  >End date:</label
                >

                <input
                  type="date"
                  id="end"
                  bind:value={endDate}
                  min="2022-01-01"
                  max="2050-01-01"
                  style="background: black; color:grey; border: 0px; font-size: 1.5em"
                />
              </div>
            </div>
          </div>
        </div>
      {:else if showImageForm}
        <div
          style="display:flex; width: 100%; height: fit-content; border: 0px solid rgb(47, 51, 54); align-items:flex-end"
        >
          <div
            style="display: flex; flex-direction:column; flex-grow: 1; justify-content:space-evenly"
          >
            <div
              style="height: 50px; border: 1px solid rgb(51, 54, 57); border-radius:14px; padding: 5px 15px; margin: 15px"
            >
              <input
                bind:value={image.value}
                type="text"
                placeholder={image.label}
                style="background: black; border: 0px; width: 100%; height: 100%; color:white; font-size: 1.2em;"
              />
            </div>
            <div
              style="height: fit-content; border: 0px solid rgb(51, 54, 57); border-radius:14px; padding: 5px 15px; margin: 15px"
            >
              <img
                src={image.value}
                alt="preview"
                style="max-height: 150px; max-width: 60%; border-radius: 3px"
              />
            </div>
          </div>
        </div>
      {/if}
      <div style="display:flex">
        <div
          style="display:flex; text-align:center; align-items:center; width: 70px; margin-left: 50px "
          on:click={() => {
            showImageForm = showImageForm ? false : true
          }}
        >
          <Fa icon={faImage} scale={1.2} />
        </div>
        <div
          style="display:flex; text-align:center; align-items:center; width: 70px"
          on:click={() => {
            showBetForm = showBetForm ? false : true
          }}
        >
          <Fa icon={faChartBar} scale={1.2} />
        </div>
        <DisplayButton
          {principal}
          label="Post"
          {signIn}
          execute={async () => {
            processing = true
            if (showBetForm) {
              await submitMarket()
            } else if (showImageForm) {
              await submitImage()
            } else {
              await submitPost()
            }
            processing = false
          }}
          {errorResponse}
          {processing}
        />
      </div>
    </div>
  </div>
  <div
    style="width: 100%; display:flex; justify-content:center; flex-direction:column; align-items:center; gap: 10px"
  >
    <div class="rowUser">
      {#each feed as post, i}
        <DisplayPost
          {auth}
          {principal}
          {signIn}
          {post}
          doNotShowBorder={i < feed.length - 1 ? false : true}
        />
      {/each}
    </div>
  </div>
</div>
