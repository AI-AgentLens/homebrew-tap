cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.279"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.279/agentshield_0.2.279_darwin_amd64.tar.gz"
      sha256 "a76cc551292446ce06e39f00d381aed82e08eb5581034a3be297c9b1562c640e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.279/agentshield_0.2.279_darwin_arm64.tar.gz"
      sha256 "b8d40ee87ce6c036724efe521a276bffdb290055f1d1b06e124acbdd33e3f310"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.279/agentshield_0.2.279_linux_amd64.tar.gz"
      sha256 "aff7442eabef935f0b24d5bae0eea63b13745f820539b33959a7fc8d17046cc6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.279/agentshield_0.2.279_linux_arm64.tar.gz"
      sha256 "e945e1f6a7cd6185c6a88c3d536ca34145431622355e36c196875af1422ecad2"
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
