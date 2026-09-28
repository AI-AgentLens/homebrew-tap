cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2277"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2277/agentshield_0.2.2277_darwin_amd64.tar.gz"
      sha256 "1be2efed6a42af4b439144e61e3835c30aba999e9f1b2df69e1792b5ade60edd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2277/agentshield_0.2.2277_darwin_arm64.tar.gz"
      sha256 "015153cdc79b27315c9c1962f2db099acd8aa47242754a72a81b3a40563f4699"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2277/agentshield_0.2.2277_linux_amd64.tar.gz"
      sha256 "a7896343c93174130754ae4b9c54ecd4dc3a2f0bbe3b1720a2b7feb6bbdae07f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2277/agentshield_0.2.2277_linux_arm64.tar.gz"
      sha256 "fae18a81bc7e829c280da62556dec6528a31ca932aeae83c100ca05f27185392"
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
