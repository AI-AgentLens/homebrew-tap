cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1891"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1891/agentshield_0.2.1891_darwin_amd64.tar.gz"
      sha256 "cafb019fe0cf8d6f5ef1bf97aef4954c4fd65791008e4fab89df9b09dd86787d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1891/agentshield_0.2.1891_darwin_arm64.tar.gz"
      sha256 "def28b75c11b33d3a66f77c37296f21a65ab7b5baf1145743c08c803568ae9b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1891/agentshield_0.2.1891_linux_amd64.tar.gz"
      sha256 "e858283183b57c92bb95396e0c1c44d51314cb79d2d581da658fe1fc570c48b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1891/agentshield_0.2.1891_linux_arm64.tar.gz"
      sha256 "0e6b4200caae71f54a8423b7a4d423452a03765a9ae3698bc74225a0e0821cc7"
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
