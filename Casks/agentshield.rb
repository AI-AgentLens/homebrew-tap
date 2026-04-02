cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.289"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.289/agentshield_0.2.289_darwin_amd64.tar.gz"
      sha256 "a4ca0b85c448e429d8f50da44b90bc957cb7f03be4c7dbda3b37f58cfc31cfaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.289/agentshield_0.2.289_darwin_arm64.tar.gz"
      sha256 "3539efa04dedead332a402130e3192969306f7c04ad17d76c054a00cd00e39bf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.289/agentshield_0.2.289_linux_amd64.tar.gz"
      sha256 "a255b710fa2023bc4968419a9e3b65c124e12cfce3c293ede2d095aab3e6ead0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.289/agentshield_0.2.289_linux_arm64.tar.gz"
      sha256 "083d5837cc3016f42ddeae700efd348cabdc968b93575e31f910bb81c66eef70"
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
