cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.842"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.842/agentshield_0.2.842_darwin_amd64.tar.gz"
      sha256 "e503051339439d2a5fcd6bef196b8c138a756c17dae67a61cae50b97814d60cc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.842/agentshield_0.2.842_darwin_arm64.tar.gz"
      sha256 "7aaad5bb2247ce728a1aeb2e19cdac4446a073dd26d5c79697b8655a0eff71d7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.842/agentshield_0.2.842_linux_amd64.tar.gz"
      sha256 "4677e353c6ece4f7f4c7dd3658245753e4e17bf5fe2f445d5c54ddeb1e9e71ba"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.842/agentshield_0.2.842_linux_arm64.tar.gz"
      sha256 "411acad4b79b1969d3568edd13d99f881810724ff5e877ee4821b507e2cd63ab"
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
