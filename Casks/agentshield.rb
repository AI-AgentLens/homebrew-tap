cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2290"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2290/agentshield_0.2.2290_darwin_amd64.tar.gz"
      sha256 "b2be11164753381db2f3a349e66560d77983415504aabfac4fc7435b3f009c33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2290/agentshield_0.2.2290_darwin_arm64.tar.gz"
      sha256 "366d7af080d17bafd07ee2350520519845bfe795eb7a822d3d57345dafc0a17e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2290/agentshield_0.2.2290_linux_amd64.tar.gz"
      sha256 "8c1cf5b6881def847a83c5820a5bb8e283f087bcbc56d5d74d869d2a1daa8542"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2290/agentshield_0.2.2290_linux_arm64.tar.gz"
      sha256 "ecc58af1a8c1f4d468a762ee2ec3b0f43b8d9317eeb9daf64a011d593cbcefa2"
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
