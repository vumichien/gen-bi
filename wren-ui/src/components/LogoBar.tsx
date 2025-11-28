import Image from 'next/image';

export default function LogoBar() {
  return (
    <Image
      src="/images/logo.png"
      alt="Detomo GenBI Platform logo"
      width={30}
      height={30}
      style={{ width: 'auto', height: 30 }}
      priority
    />
  );
}
