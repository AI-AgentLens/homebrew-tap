cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.217"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.217/agentshield_0.2.217_darwin_amd64.tar.gz"
      sha256 "2312f80e671e907f915671b5ff3a97c36b1c7e193fd3af14d89e14737f652351"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.217/agentshield_0.2.217_darwin_arm64.tar.gz"
      sha256 "68dd3c32d5fbb5e6bbccdc46d65696aeb27ed6fc709def07d3a6e6300d8168be"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.217/agentshield_0.2.217_linux_amd64.tar.gz"
      sha256 "50b33dd52e832e3b86033745c679d12d09d51f5278b64d36a7c951ac9a15bd05"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.217/agentshield_0.2.217_linux_arm64.tar.gz"
      sha256 "4fa8cbcbad1e6c7011d526ed884600e85a2bab255e75ab49b5afd58197c8289a"
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
