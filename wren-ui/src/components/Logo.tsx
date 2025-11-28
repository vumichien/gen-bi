import Image from 'next/image';

interface Props {
  size?: number;
}

export const Logo = (props: Props) => {
  const { size = 30 } = props;
  return (
    <Image
      src="/images/logo.png"
      alt="Detomo GenBI Platform logo"
      width={size}
      height={size}
      style={{ width: size, height: 'auto' }}
    />
  );
};
