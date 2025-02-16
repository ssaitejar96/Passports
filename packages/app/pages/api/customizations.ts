import { initializeApp } from 'firebase/app';
import { collection, doc, getDocs, getFirestore, query, where } from 'firebase/firestore/lite';
import type { NextApiRequest, NextApiResponse } from 'next'
import { firebaseConfig } from '../../components/constants';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
    switch (req.method) {
        case "POST":
            // Create a connection to the firebase DB.
            const app = initializeApp(firebaseConfig);
            const db = getFirestore(app);
            const urlCol = collection(db, 'customizations');
            getDocs(query(urlCol, where("contractAddr", "in", req.body.addresses)))
                .then((memberships) => {
                    const data: {[key: string]: Record<string, string> | undefined} = {};
                    memberships.forEach((doc) => {
                        const docData = doc.data();
                        data[docData["contractAddr"]] = docData;
                    });
                    res.status(200).json({customizations: data});
                });
            break;
        default:
            res.setHeader("Allow", ["POST"]);
            res.status(405).end(`Method ${req.method} Not Allowed`);
            break;
    }
}