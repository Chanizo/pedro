import dynamic from "next/dynamic";
import Head from "next/head";

const MyAwesomeMap = dynamic(() => import("../../components/map"), {ssr: false})

export default function MyMap() {
    return (
        <>
            <Head>
                <title>My awesome map !</title>
            </Head>
            <main>
                <div style={{height: '400px'}}>
                    <MyAwesomeMap/>
                </div>
            </main>
        </>
    )
}
