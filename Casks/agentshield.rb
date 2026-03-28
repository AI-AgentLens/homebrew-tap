cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.149"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.149/agentshield_0.2.149_darwin_amd64.tar.gz"
      sha256 "5517d98ffdba47fbde340d7971a4ffd586492efb87e1edd97414c44eac441d06"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.149/agentshield_0.2.149_darwin_arm64.tar.gz"
      sha256 "56a31bc0e81052980a1ac88aae0cb6c757eb041345e2841d5bda7cb82cdb81c3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.149/agentshield_0.2.149_linux_amd64.tar.gz"
      sha256 "3b601ea80bca04001fe9a1cb5604d6fd7570c9ffa7c558aa97df9724638d5b69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.149/agentshield_0.2.149_linux_arm64.tar.gz"
      sha256 "bf556d5fd11adbe54f751d59b5eeb32c77199d865a6e135e22b9d1ed3fc95ea7"
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
