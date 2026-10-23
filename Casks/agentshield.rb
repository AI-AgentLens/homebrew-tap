cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2511"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2511/agentshield_0.2.2511_darwin_amd64.tar.gz"
      sha256 "5acc008557e9ebb9e92f481132d873310e08b88451fd28ad192c34d02580a7de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2511/agentshield_0.2.2511_darwin_arm64.tar.gz"
      sha256 "a83742180259b5f19fd6def2aaffed471a089d1ed9f5492fa813881d83fa71d2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2511/agentshield_0.2.2511_linux_amd64.tar.gz"
      sha256 "6577e55bcb81dd3e7578c794f5ffbe4bcf17028f2771ce5f0c4acbf9f67924de"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2511/agentshield_0.2.2511_linux_arm64.tar.gz"
      sha256 "4441fa75975b1f9b1d96cc4b5fd8301422575943a0be06ed7c8a7f4d05f096c4"
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
