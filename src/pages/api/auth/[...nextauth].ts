import NextAuth from "next-auth"
import GithubProvider from "next-auth/providers/github"

import { query as q } from "faunadb"
import {fauna} from "../../../services/fauna"

export default NextAuth({
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,     
    }),
  ],
  callbacks: {
   async signIn(params) {
       await fauna.query(
        q.Create(
            q.Collection('users')
            ,{data:{email: params.email}}
        )
       )
       return true; 
    },
  },
})