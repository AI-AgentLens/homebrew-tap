cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1458"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1458/agentshield_0.2.1458_darwin_amd64.tar.gz"
      sha256 "b06ce5ad6252c209a5c348292d48c34ceeb11bc21154d6d067c7113f5805368d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1458/agentshield_0.2.1458_darwin_arm64.tar.gz"
      sha256 "3c624244bb7a89022e8959339deb3f07bf80ff3258b2e122c698b84d6a31a043"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1458/agentshield_0.2.1458_linux_amd64.tar.gz"
      sha256 "219f5931c46be8d0bc7e7713d01cea4bf60b5ae2eb30260a5adfb8f19784e668"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1458/agentshield_0.2.1458_linux_arm64.tar.gz"
      sha256 "4654e4cd445a8ec49f2f9b07352883a40254fc9503894cf568c9b26b579b25b8"
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
