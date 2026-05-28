cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1129"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1129/agentshield_0.2.1129_darwin_amd64.tar.gz"
      sha256 "f52fefb0c69ffd396c6b0028d87c2469254b91eff8b0185cafd9ed8d1fd28774"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1129/agentshield_0.2.1129_darwin_arm64.tar.gz"
      sha256 "52fb77e13366fdc9e869d22a10a97340ffc5c9b6a9b2238753ae2642c03bb48c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1129/agentshield_0.2.1129_linux_amd64.tar.gz"
      sha256 "07ac91cc1bfd60896397906574515fbb2fd4c1cdb5070972650818e9ba0260e5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1129/agentshield_0.2.1129_linux_arm64.tar.gz"
      sha256 "3f4af74d8ab703a4d0c56e08130c1db67f1a073cf55f1d505888338979dc4319"
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
