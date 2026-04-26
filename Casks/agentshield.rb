cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.754"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.754/agentshield_0.2.754_darwin_amd64.tar.gz"
      sha256 "dc83d436e7e7cb0251a91e9f431919f4f0c32ba0a769c989ab9bcb023400d8f7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.754/agentshield_0.2.754_darwin_arm64.tar.gz"
      sha256 "144429b12de8abc8ecb7738037fba7529ac93e65b3e6a1f73f429e2d6789a0e4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.754/agentshield_0.2.754_linux_amd64.tar.gz"
      sha256 "a4c6135a0fc04a631ec28add020e50e059f3138e9e1ee154d65c46bfe712fe02"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.754/agentshield_0.2.754_linux_arm64.tar.gz"
      sha256 "54126bca0dc1ca7b6d439470a26193399d89c59a55bfda37cadd455f5816e2f5"
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
