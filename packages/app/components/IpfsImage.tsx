import { shimmer, toBase64 } from "./constants";
import Image from "next/image";
import { styled } from "@cabindao/topo";

const IpfsImage = ({
  cid,
  height,
  width,
}: {
  cid: string;
  height?: string | number;
  width?: string | number;
}) => {
  return (
    <Image
      src={`https://ipfs.io/ipfs/${cid}`}
      alt={"thumbnail"}
      width={height || 300}
      height={width || 200}
      placeholder="blur"
      blurDataURL={`data:image/svg+xml;base64,${toBase64(shimmer(700, 475))}`}
    />
  );
};

export default IpfsImage;
