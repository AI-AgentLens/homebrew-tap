cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.247"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.247/agentshield_0.2.247_darwin_amd64.tar.gz"
      sha256 "f66e1a40380604c887cfac8c2edcb90907214451a6402937620d6abc08e64b13"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.247/agentshield_0.2.247_darwin_arm64.tar.gz"
      sha256 "efd7db5a58a39150e4e51afb31c879ffa67576acd5043bad9eb91bbcbef44097"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.247/agentshield_0.2.247_linux_amd64.tar.gz"
      sha256 "d58390fc8a54fa5d2d6eb817d133cb63bf2da3f05849c3256e1c86e61114d02e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.247/agentshield_0.2.247_linux_arm64.tar.gz"
      sha256 "4c506a796047f0a9b1e368aaa9290d887cf7cb78f455eee3c19b27411d75af9c"
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
