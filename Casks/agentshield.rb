cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.69"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.69/agentshield_0.2.69_darwin_amd64.tar.gz"
      sha256 "4e281dd0373875219bb8cc30ae20950643dba0a808d1eb7fc681c18cdf51e5f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.69/agentshield_0.2.69_darwin_arm64.tar.gz"
      sha256 "d058a0ed6869f16753843c5a9279085dd58d82ec13c94ca48c71c765e1c47845"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.69/agentshield_0.2.69_linux_amd64.tar.gz"
      sha256 "7004b644facc38c0e573e0b28c99058cb57a53da059ff86544eedacdc5e67b7d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.69/agentshield_0.2.69_linux_arm64.tar.gz"
      sha256 "6d00e05522141445d13d832139c15495530625e178ebe3321fcc42a42a97c891"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
