cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1611"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1611/agentshield_0.2.1611_darwin_amd64.tar.gz"
      sha256 "a479148945aa366666364fd17c72fa6b2014e536283dc6f5b580a0b1ec7ab76d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1611/agentshield_0.2.1611_darwin_arm64.tar.gz"
      sha256 "c5746f5a1cc304ce061d078f436d6521504a4b7e4cd2f163652e12d9f87bab49"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1611/agentshield_0.2.1611_linux_amd64.tar.gz"
      sha256 "1536f509913f8e165b3dedcd1792a4b4d53a9e69c53680dbf37d55e722313b33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1611/agentshield_0.2.1611_linux_arm64.tar.gz"
      sha256 "ddf086ef810bf65cd794efc747c67c53a763543b7577980ecfaa1e05828431b9"
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
