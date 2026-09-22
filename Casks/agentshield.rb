cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2222"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2222/agentshield_0.2.2222_darwin_amd64.tar.gz"
      sha256 "df51dccf7c1d00704148ed07ed1c19430f8386162e5382cdb081c6329b8e7210"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2222/agentshield_0.2.2222_darwin_arm64.tar.gz"
      sha256 "d99d88f1505f55088e120987829d937280e4ebf8a50ac5a64b99a6bd798e50fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2222/agentshield_0.2.2222_linux_amd64.tar.gz"
      sha256 "734ae0cb53760740ca1b741c72987150df8d4f8783b6c94d9ac96fb9ff3fcda2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2222/agentshield_0.2.2222_linux_arm64.tar.gz"
      sha256 "dc110629f279954b89caa0986fabfce3a070ce685f8bde8d6eba972ec2317fef"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
