cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2019"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2019/agentshield_0.2.2019_darwin_amd64.tar.gz"
      sha256 "e9a8f4cf7595a2619b68990b31af84beefe17ab3dc9099e85980c5353025b535"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2019/agentshield_0.2.2019_darwin_arm64.tar.gz"
      sha256 "f55b95d623da1702421110454b34913a24f0383a5822167db98fe9713c97fe23"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2019/agentshield_0.2.2019_linux_amd64.tar.gz"
      sha256 "7dec19017b31f26b23055b00ecc9de2aa7fbf77a1657fa2dc6623d8b14f61e92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2019/agentshield_0.2.2019_linux_arm64.tar.gz"
      sha256 "f43a393bf22b4d8dbdc8a65572d8c40db472cd4645097c3bb931edcc47baa6b7"
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
